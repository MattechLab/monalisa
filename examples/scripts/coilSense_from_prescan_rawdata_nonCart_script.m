reconDir = 'C:\Users\helbi\Documents\MattechLab\recon_eva';

bodyCoilFile     = [reconDir, '/C/meas_MID00539_FID154917_BEAT_LIBREon_eye_BC_BC.dat'];
arrayCoilFile    = [reconDir, '/C/meas_MID00540_FID154918_BEAT_LIBREon_eye_SC_BC.dat'];

%% Read and print metadata from the twix
bmTwix_info(bodyCoilFile)
bmTwix_info(arrayCoilFile)

%% The input initialization is not automatizable, since the name/content of
% the variables depends on the sequence programmed. For the moment we just
% read and print the twixinfo and you need to adjust the parameters yourself

%% Maybe: write a function for automate ISMR rawData format(Standard) reading.
% All trajectory information, to generate the trajectory. 
N            = 128;
nSeg         = 22; 
nShot        = 419; 

% This is the FoV set during the acquisition
FoV          = [240, 240, 240]; 

% nShotOff depends on magnitude shown in figure "TwixInfo Magnitude"
nShotOff     = 10; 

% Matrix size of the cartesian grid in the k-space
N_u          = [48, 48, 48]; 

% K-space resolution for the reconstruction (has to be the same as the
% final reconstruction)
reconFoV = 480; % magic number
dK_u         = [1, 1, 1]./reconFoV;

% Number of coils (channels)
nCh_array    = 42; 
nCh_body     = 2;

% We will need to ask for a predefined format. Hence we need to read the 
% data outside and pass the y_body, t has to be computed by the user.  
% We use trajectory in using the physical dimensions without convention 
% [-0.5, 0.5]
% You have to see how much data needs to be discarded by looking at the
% graph, you don't want to keep data if you are not in steady-state.
[y_body, t, ve] = bmCoilSense_nonCart_dataFromTwix( bodyCoilFile, ...
                                                    N_u, ...
                                                    N, ...
                                                    nSeg, ...
                                                    nShot, ...
                                                    nCh_body, ...
                                                    FoV, ...
                                                    nShotOff);

% Same for array coils 
y_array         = bmCoilSense_nonCart_dataFromTwix( arrayCoilFile, ...
                                                    N_u, ...
                                                    N, ...
                                                    nSeg, ...
                                                    nShot, ...
                                                    nCh_array, ...
                                                    FoV, ...
                                                    nShotOff);

% compute the gridding matrices (Gn = approximation of inverse, Gu = Forward,
% Gut = transposed of Gu) Gn and Gut are both backward
[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u); 

% You need to Reassign the xmin, xmax & ymin, ymax & zmin, zmax 
% To do it you need to run the function below (bmCoilSense_nonCart_mask)
% control + E: to change the tresholds
% shift + E: to set the constast chosen

% Box excluding coordinates
x_min = 2; 
x_max = 39;

y_min = 10; 
y_max = 41;

z_min = 4; 
z_max = 48;

% Two thresholds
th_RMS = 14; 
th_MIP = 10; 


close_size = []; 
open_size  = []; 

% Mask computation, the two thresholds to exclude artifacts from the region
% where there is no signal, like air in the lungs: 
% 1 for the Root mean square
% 1 for the Maximum intensity projection

%% Make some work to try to automate it. Define two scripts.
% (Automatic and Advanced)
m = bmCoilSense_nonCart_mask(   y_body, Gn, ...
                                x_min, x_max, ...
                                y_min, y_max, ...
                                z_min, z_max, ...
                                th_RMS, th_MIP, ...
                                close_size, ...
                                open_size, ...
                                true);

% Select one body coil and compute its sensitivity
[y_ref, C_ref] = bmCoilSense_nonCart_ref(y_body, Gn, m, []); 



% Estimate the coil sensitivity of each surface coil using one body coil
% image as reference image C_c = (X_c./x_ref)
C_array_prime = bmCoilSense_nonCart_primary(y_array, y_ref, C_ref, Gn, ve, m);


% Do a recon, predending the selected body coil is one channel among the
% others, and optimize the coil sensitivity estimate by alternating steps
% Of gradient descent (X,C)
nIter = 5; 
[C, convCond_out, x] = bmCoilSense_nonCart_secondary(y_array, C_array_prime, y_ref, C_ref, Gn, Gu, Gut, ve, nIter, true); 


