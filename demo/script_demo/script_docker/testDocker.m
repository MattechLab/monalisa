addpath(genpath('/usr/src/app/src'))
% Complile the source code in the Docker
compileScript()
% Run some reconstruction

m = '/usr/src/app/recon_eva/mitosius'; 

y   = bmMitosius_load(m, 'y'); 
t   = bmMitosius_load(m, 't'); 
ve  = bmMitosius_load(m, 've'); 

N_u     = [80, 80, 80]; % Size of the Virtual cartesian grid in the fourier space (regridding)
n_u     = [80, 80, 80]; % Image size (output)
dK_u    = [1, 1, 1]./480; % Spacing of the virtual cartesian grid
nFr     = 20; 
% best achivable resolution is 1/ N_u*dK_u If you have enogh coverage

load('/usr/src/app/recon_eva/C/C.mat'); 
C = bmImResize(C, [48, 48, 48], N_u);

%%

x0 = cell(nFr, 1);
for i = 1:nFr
    x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
end
