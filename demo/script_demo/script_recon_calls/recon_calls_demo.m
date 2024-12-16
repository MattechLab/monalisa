
m = '/Users/mauroleidi/Desktop/recon_eva/mitosius'; 

y   = bmMitosius_load(m, 'y'); 
t   = bmMitosius_load(m, 't'); 
ve  = bmMitosius_load(m, 've'); 

N_u     = [80, 80, 80]; % Size of the Virtual cartesian grid in the fourier space (regridding)
n_u     = [80, 80, 80]; % Image size (output)
dK_u    = [1, 1, 1]./480; % Spacing of the virtual cartesian grid
nFr     = 20; % amount of frames
% best achivable resolution is 1/(N_u*dK_u) If you have enough coverage

load('/Users/mauroleidi/Desktop/recon_eva/C/C.mat'); 
C = bmImResize(C, [48, 48, 48], N_u);

%%
[Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

%%
x0 = cell(nFr, 1);
for i = 1:nFr
    x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
end
bmImage(x0);

%% tevaMorphosia_no_deformField
nIter         = 30; % iterations before stopping
witness_ind   = [];
witness_label = 'tevaMorphosia_d0p1_r1_nCGD4';
delta         = 0.1;
rho           = 10*delta;
nCGD          = 4;
ve_max        = 10*prod(dK_u(:));

x = bmTevaMorphosia_chain(  x0, ...
                            [], [], ...
                            y, ve, C, ...
                            Gu, Gut, n_u, ...
                            [], [], ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            nIter, ...
                            bmWitnessInfo(witness_label, witness_ind));

bmImage(x)
