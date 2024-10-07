windowSizeSeconds = 150;
%path where to save mitosius
mitosius_savepath = '/Users/mauroleidi/Desktop/20240923_Data/JB/mitosius/'; 
savefolder = [mitosius_savepath, num2str(windowSizeSeconds), 'seconds_PSF'];

% path to the rawdatafile (in this case Siemens raw data)
f = '/Users/mauroleidi/Desktop/20240923_Data/JB/Raw_Data/rawdata/meas_MID00485_FID176652_BEAT_LIBREoff_RS_GoldenStep.dat'; 
autoFlag = false;             % Set whether the validation UI is shown
% Create the appropriate reader based on the file extension
reader = createRawDataReader(f, autoFlag);
p = reader.acquisitionParams;
p.selfNav_flag = true;
p.traj_type = 'full_radial3_phylotaxis_chris';

% compute trajectory points. This function is really wird. ASK BASTIEN.
y_tot = reader.readRawData(true,true); % get raw data without nshotoff and SI

t_tot   = bmTraj(p); % get trajectory without nshotoff and SI
% compute volume elements
ve_tot  = bmVolumeElement(t_tot, 'voronoi_full_radial3' ); 

FoV = p.FoV;
matrix_size = FoV/3;
N_u     = [matrix_size, matrix_size, matrix_size];
n_u     = [matrix_size, matrix_size, matrix_size];
dK_u    = [1, 1, 1]./384;

% Load the coil sensitivity previously measured
load('/Users/mauroleidi/Desktop/20240923_Data/JB/coil_sensitivity_map_2024-09-28_21-13.mat');

C = bmImResize(C, [48, 48, 48], N_u); 


% Normalization (probably to convege better)
% Note you can normalize the rawdata and the image will be normalized
% This is because the Fourier transform is linear
% F(f(.)/a) =  F(f(.))/a
x_tot = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, n_u, dK_u); 
bmImage(x_tot)
temp_im = getimage(gca); 
bmImage(temp_im); 
temp_roi = roipoly; 
normalize_val = mean(temp_im(temp_roi(:))); 

%% only once !!!!
y_tot = y_tot/normalize_val; 

nshotoff = p.nShot_off;
% Compute binning
cMask = mleGenerateSequentialBinningMasks(windowSizeSeconds, reader,true);
disp(size(cMask))
cMask = reshape(cMask, [size(cMask,1), p.nSeg, size(cMask,2)/p.nSeg]); %MAGIC NUMBERS
cMask(:, 1, :) = [];  % remove the SI projection
cMask(:, :, 1:p.nShot_off) = []; % remove non steady state
disp(size(cMask))

if size(cMask, 1) > 10
    cMask = cMask(1:10, :, :);  % Keep only the first 10 images
end

cMask = bmPointReshape(cMask); 



% Run the mitosis function and compute volume elements

[y, t] = bmMitosis(y_tot, t_tot, cMask); 
y = bmPermuteToCol(y); 

ve  = bmVolumeElement(t, 'voronoi_full_radial3'); 

% Save all the resulting datastructures on the disk. You are now ready
% to run your reconstruction

bmMitosius_create(savefolder, y, t, ve); 


















