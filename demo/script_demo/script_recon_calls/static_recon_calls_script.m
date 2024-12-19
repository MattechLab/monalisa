%% Setting Path

% This should store the path to the monalisa directory in the variable 
% 'monalisa_dir'. If it does not work just do it manually.  
[monalisa_dir, ~, ~] = fileparts(  matlab.desktop.editor.getActiveFilename  ); 
for i = 1:3
    [monalisa_dir, ~, ~] = fileparts(monalisa_dir); 
end

% Add the paths to all Monalisa subdirectories.  
src_dir = [monalisa_dir, filesep, 'src']; 
addpath(genpath(src_dir));

%% Load data-set

% To test single-frame or chain reconstructions, load one of the 
% three following demonstration dataset: 

% demo_data_1 -------------------------------------------------------------
% load([  monalisa_dir, filesep, ...
%         'demo', filesep, ...
%         'data_demo', filesep, ...
%         'data_1_static_radial_simulated_from_XCAT', filesep, ...
%         'data.mat']); 
%    
% This dataset was simulated with the XCAT phantom. 
%
% W. P. Segars, G. Sturgeon, S. Mendonca, J. Grimes, and B. M. W. Tsui, 
% ‘4D XCAT phantom for multimodality imaging research’, 
% Med. Phys., vol. 37, no. 9, Art. no. 9, Sep. 2010, 
% doi: 10.1118/1.3480985.
%     
% END_demo_data_1 ---------------------------------------------------------



% demo_data_2 -------------------------------------------------------------
load([  monalisa_dir, filesep, ...
        'demo', filesep, ...
        'data_demo', filesep, ...
        'data_2_static_radial_simulated_from_cartesian', filesep, ...
        'data.mat']); 

% This radial data-set was acquired on a healthy volunteer (one of the main 
% invesigator of the monalisa toolbox) in accordance with the local 
% ethical rules. That data-set ca be used by anybody for any academical 
% research purpose. 
% 
% END_demo_data_2 ---------------------------------------------------------



% demo_data_3 -------------------------------------------------------------
% load([  monalisa_dir, filesep, ...
%         'demo', filesep, ...
%         'data_demo', filesep, ...
%         'data_3_static_radial_measured', filesep, ...
%         'data.mat']); 
% 
% This radial data-set was simulated from a cartesian data set acquired  
% on a healthy volunteer (one of the main invesigator of the monalisa  
% toolbox)in accordance with the local ethical rules. 
% That data-set ca be used by anybody for any academical research purpose. 
% 
% demo_data_3 -------------------------------------------------------------



%% Chosing the current directory

% The results of iterative reconstrucitons will automatically be
% saved in the current directory. Please set you current directory so that
% files can be written in it. 

% As an example, we set here the 'temp' directory of the Monalisa 
% directory as current directory: 
cd([monalisa_dir, filesep, 'temp']); 





%% volume_elements: From the trajectory t we compute volume elements ve.

% This depends only on the trajectory. There is a function
% bmVolumeElement_xxxxxx for each type of trajectory. For special
% trajectories you may have to implement your own volume-element function. 
% In the present case, we have a 2D radial trajectory. 

% For single-frame reconstruction, the trajectory t is a double precision 
% array of size [frDim, nPt], where frDim is the frame dimension 
% (spatial dimension of the image) and nPt is the number of points 
% in the trajectory. 

ve = bmVolumeElement(t, 'voronoi_full_radial2'); 

%% Adjust C size
% The coil-sensitivity C is usually saved with low array-size. We
% interpolate it to fit the frame-size: 

C_size = size(C); 
C_size = C_size(1:frDim); 
C = bmImResize(C, C_size, frSize);


%% Mathilda

% This is our gridded zero-padded reconstruction for non-cartesian data. 
% Mathilda does the same as Nasha (see hereafter) mathematically, 
% but without computing any gridding matrix. 
% 
% Mathilda is a single-frame reconstruciton.  

x0 = bmMathilda(y, t, ve, C, N_u, frSize, dK_u, [], [], [], []);

bmImage(x0);

%% Gridding Matrices

% The sparse matrices computed here are the gridding matrices for
% non-cartesain reconstructions. They depend on the trajectory, FoV (dK_u), 
% and grid-size N_u. 
%
% Gu is the forward-gridding matrix and Gut is its transposed matrix. 
% Gn is the inverse griddoing matrix. 

[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);


%% Nasha

% It performs the same like Mathilda, but with gridding matrix Gn. We never
% use Nasha, excepted if we have to repeat the exact same gridded recon 
% manytimes. But it is rarely the case. A gridded recon is usually done 
% only one time for one data set. Therefore we use rather Mathilda. 

x0 = bmNasha(y, Gn, frSize, C, []);


% Use the arrows to run through different frames in the displayed image. 
bmImage(x0);

%% Sensa

% This is our iterative-SENSE implementation for non-cartesian data. 
% It is a single-frame reconstruction that consists in minimizing the
% data-fidelity term with the conjugate gradient descent method. 
% There is no sharing of information between frames. 
% The result may therefore be quite bad for very 
% undersampled data. But this recon is important because it has a very 
% important geometrical meaning in the theory of reconstruction 
% and it has some application for some special cases. 

nIter               = 30;
nCGD                = 4;
witness_ind         = [1, nIter];
witness_label       = 'sensa_frame_1';
save_witnessIm_flag = false; 
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);
ve_max              = 10*prod(dK_u(:));

x   = bmSensa(  x0, y, ve, C, Gu, Gut, frSize,...
                nCGD, ve_max, ...
                nIter, witnessInfo);

bmImage(x)

%% Steva

% This is a least-square regularized reconstruction for non-cartesian data,
% where the regularization is the l1-norm of the spatial gradient of the
% image. 
% It is a static (single-frame) reconstruction that consists of minimizing 
% the objective function with the ADMM algorithm. 
% Delta is the regularization weight. Parameter Rho is the convergence 
% parameter for ADMM. 
%


nIter               = 30;
nCGD                = 4;
witness_ind         = [1, nIter];
witness_label       = 'steva_frame_1';
save_witnessIm_flag = false; 
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);
ve_max              = 10*prod(dK_u(:));

delta               = 1; 
rho                 = 10*delta;  

x             = bmSteva(    x0, [], [], y, ve, C, Gu, Gut, frSize, ...
                            delta, rho, nCGD, ve_max, ...
                            nIter, witnessInfo); 
                        
bmImage(x); 

%% Sleva

% This is a least-square regularized reconstruction for non-cartesian data,
% where the regularization is the l2-norm of the image. 
% It is a single-frame reconstruction that consists in minimizing the
% objective function with the conjugate gradient descent method. 
% Delta is the regularization weight. 


nIter               = 30;
nCGD                = 4;
witness_ind         = [1, nIter];
witness_label       = 'sleva_frame_1';
save_witnessIm_flag = false; 
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);
ve_max              = 10*prod(dK_u(:));

delta         = 2; 

x             = bmSleva(x0, ...
                        y, ve, C, ...
                        Gu, Gut, frSize, ...
                        delta, 'normal', ...
                        nCGD, ve_max, ...
                        nIter, witnessInfo  ); 

% Use the arrows to run through different frames in the displayed image. 
bmImage(x); 

