


reconDir = '/Users/mauroleidi/Desktop/recon_eva'; 
f = [reconDir, '/raw_data/meas_MID00530_FID154908_BEAT_LIBREon_eye.dat']; 


bmTwix_info(f); 
myTwix = bmTwix(f); 


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
p.nShot_off       = 10; 
p.roosk_flag      = false;

p.FoV             = [480, 480, 480];

p.traj_type       = 'full_radial3_phylotaxis';


p.refresh; 


y_tot   = bmTwix_data(myTwix, p); 
t_tot   = bmTraj(p); 
ve_tot  = bmVolumeElement(t_tot, 'voronoi_full_radial3' ); 


N_u     = [480, 480, 480]/2;
n_u     = [480, 480, 480]/2;
dK_u    = [1, 1, 1]./480;


load('/Users/mauroleidi/Desktop/recon_eva/C/C.mat'); 
C = bmImResize(C, [48, 48, 48], N_u); 


%%

x_tot = bmMathilda(y_tot, t_tot, ve_tot, C, N_u, n_u, dK_u); 
bmImage(x_tot)

%%

temp_im = getimage(gca); 
bmImage(temp_im); 
temp_roi = roipoly; 
normalize_val = mean(temp_im(temp_roi(:))); 

%% only once !!!!
y_tot = y_tot/normalize_val; 


%%

load('/Users/mauroleidi/Desktop/recon_eva/other/cMask.mat'); 

cMask = reshape(cMask, [20, 22, 2055]); 
cMask(:, 1, :) = []; 
cMask(:, :, 1:p.nShot_off) = []; 
cMask = bmPointReshape(cMask); 


%%

[y, t] = bmMitosis(y_tot, t_tot, cMask); 

y = bmPermuteToCol(y); 

ve  = bmVolumeElement(t, 'voronoi_full_radial3' ); 

%%

m = '/Users/mauroleidi/Desktop/recon_eva/mitosius'; 
bmMitosius_create(m, y, t, ve); 


















