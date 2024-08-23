windowSizeSeconds = 10;
reconDir = '/Users/mauroleidi/Desktop/recon_eva';

% path to the rawdatafile (in this case Siemens raw data)
f = [reconDir, '/raw_data/meas_MID00530_FID154908_BEAT_LIBREon_eye.dat']; 
% Display infos
bmTwix_info(f); 
% read raw data
myTwix = bmTwix(f); 

% Initialize and fill in the parameters: This in theory can be automated;
% However Bastien told us that it can lead to errors. In addition we should
% be indipendent from the specific file format used.
p = bmMriAcquisitionParam([]); 
p.name            = [];
p.mainFile_name   = 'meas_MID00530_FID154908_BEAT_LIBREon_eye.dat';

p.imDim           = 3;
p.N     = 480;  
p.nSeg  = 22;  
p.nShot = 2055;  
p.nLine = 45210;  
p.nPar  = 1;  

p.nLine           = double([]);
p.nPt             = double([]);
p.raw_N_u         = [480, 480, 480];
p.raw_dK_u        = [1, 1, 1]./480;

p.nCh   = 42;  
p.nEcho = 1; 

p.selfNav_flag    = true;
% This was estimated in the coil sensitivity computation
p.nShot_off       = 10; 
p.roosk_flag      = false;
% This is the full FOV not the half FOV
p.FoV             = [480, 480, 480];
% This sets the trajectory used
p.traj_type       = 'full_radial3_phylotaxis';

% Fill in missing parameters that can be deduced from existing ones.
p.refresh; 

% read rawdata
y_tot   = bmTwix_data(myTwix, p);
% compute trajectory points. This function is really wird. ASK BASTIEN.
t_tot   = bmTraj(p); 
% compute volume elements
ve_tot  = bmVolumeElement(t_tot, 'voronoi_full_radial3' ); 


N_u     = [480, 480, 480]/2;
n_u     = [480, 480, 480]/2;
dK_u    = [1, 1, 1]./480;

% Load the coil sensitivity previously measured
load('/Users/mauroleidi/Desktop/recon_eva/C/C.mat');

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

% compute nshotoff
bmTwix_info(f);

nshotoff = 10;

% Load the masked coil sensitivity 
cMask = generateSequentialBinningMasks(windowSizeSeconds, f, nshotoff,true);

cMask = reshape(cMask, [size(cMask,1), 22, 2055]); 
cMask(:, 1, :) = []; 
cMask(:, :, 1:p.nShot_off) = []; 
cMask = bmPointReshape(cMask); 


% Run the mitosis function and compute volume elements

[y, t] = bmMitosis(y_tot, t_tot, cMask); 
y = bmPermuteToCol(y); 

ve  = bmVolumeElement(t, 'voronoi_full_radial3'); 

% Save all the resulting datastructures on the disk. You are now ready
% to run your reconstruction
m = '/Users/mauroleidi/Desktop/recon_eva/mitosius_sequential'; 
bmMitosius_create(m, y, t, ve); 


















