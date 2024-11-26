%% Paths - Replace for your own case
% Path to the rawdatafile (Siemens raw data or ISMRMRD)
filePath = '/Users/cag/Documents/Dataset/1_Pilot_MREye_Data/Sub001/230928_anatomical_MREYE_study/MR_EYE_Subj01/RawData/meas_MID00453_FID57919_BEAT_LIBREon_eye.dat';

% Previously generated coil sensitivity and binmasks
CMatPath = '/Users/cag/Documents/Dataset/241017_T1/Sub001/T1_LIBRE_Binning/C/C.mat';
MaskPath = '/Users/cag/Documents/Dataset/241017_T1/Sub001/T1_LIBRE_Binning/other/eMask_th0.75.mat';
% Mitosius save path
mitosiusPath = '/Users/cag/Documents/Dataset/241017_T1/Sub001/T1_LIBRE_Binning/mitosius';


f = filePath;
% These functions use a function not written by Bastien so they are outside the repo
addpath('..\..\..\twix_for_monalisa\')

autoFlag = false;             % Set whether the validation UI is shown
% Create the appropriate reader based on the file extension
reader = createRawDataReader(f, autoFlag);

p = reader.acquisitionParams;
p.selfNav_flag = true;
p.traj_type = 'full_radial3_phylotaxis';

% Initialize and fill in the parameters: This in theory can be automated;
p.raw_N_u         = [480, 480, 480];
p.raw_dK_u        = [1, 1, 1]./480;
 

%% Read raw data
y_tot = reader.readRawData(true,true); % get raw data without nshotoff and SI
% compute trajectory points
t_tot   = bmTraj(p); % get trajectory without nshotoff and SI
% compute volume elements
ve_tot  = bmVolumeElement(t_tot, 'voronoi_full_radial3' ); 


FoV = p.FoV;
matrix_size = 80;
N_u     = [matrix_size, matrix_size, matrix_size];
n_u     = [matrix_size, matrix_size, matrix_size];
dK_u    = [1, 1, 1]./FoV;

% Load the coil sensitivity previously measured
load(CMatPath); 
C = bmImResize(C, [48, 48, 48], N_u); 


% Normalization (probably to convege better)
% Note you can normalize the rawdata and the image will be normalized
% This is because the Fourier transform is linear
% F(f(.)/a) =  F(f(.))/a
%%
x_tot = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, n_u, dK_u); 
bmImage(x_tot)
temp_im = getimage(gca); 
bmImage(temp_im); 
temp_roi = roipoly; 
normalize_val = mean(temp_im(temp_roi(:))); 

%% only once !!!!
y_tot = y_tot/normalize_val; 
%%

% Load the binning mask
load(MaskPath); 
% Get the bin number and remove non steady state and SI
nMasks = size(Mask,1);
Mask = reshape(Mask, [nMasks, p.nSeg, p.nShot]); 
Mask(:, 1, :) = []; 
Mask(:, :, 1:p.nShot_off) = []; 
Mask = bmPointReshape(Mask); 


% Run the mitosis function and compute volume elements

[y, t] = bmMitosis(y_tot, t_tot, Mask); 
y = bmPermuteToCol(y); 

ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

% Save all the resulting datastructures on the disk. You are now ready
% to run your reconstruction
m = mitosiusPath;
bmMitosius_create(m, y, t, ve); 


















