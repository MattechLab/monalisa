%% In this script we simply show how to use the data prepared in the previous
%% steps to finilize the reconstruction process. 
% This step is fairly simple, since all the work was done in the previous
% steps. Monalisa offers several different reconstructions that we will
% test below
%% Our reconstructions expect follwing parameters:
%- ``y``, the raw data evaluated in the bins: a [Nfr,1] cells, 
% with each cell of shape [Npointsperline*Nlines, Nchannels]
%- ``t``, trajectory evaluated in the bins: a [Nfr,1] cells, 
% with each cell of [3,Npointsperline,Nlines]
%- ``ve``, the volume elements evaluated in the bins: a [Nfr,1] cells, 
% with each cell of [1, Npointsperline*Nlines]
%- ``C``, the estimated coil sensitivity: a 4D complex double array of size [Nx Ny Nz nChannels]

%% Load the data from the mitosius
% Define paths for data and results
[baseDir, ~, ~] = fileparts(  matlab.desktop.editor.getActiveFilename  );
dataDir = fullfile(baseDir, '..','..', 'data_demo','data_8_tutorial_1');   % Data folder
resultsDir = fullfile(dataDir, 'results');  % Results folderv

%% Step 0: If you haven't done it already add src to your MATLAB PATH
addpath(genpath(srcDir))

% File paths
brainScanFile = fullfile(dataDir, 'brainScan.dat'); 
coilSensitivityPath = fullfile(resultsDir, 'coil_sensitivity_map.mat');  
allLinesBinningspath = fullfile(resultsDir, 'mitosius_allLines');  
seqBinningspath = fullfile(resultsDir, 'mitosius_sequential');  

y   = bmMitosius_load(allLinesBinningspath, 'y');
t   = bmMitosius_load(allLinesBinningspath, 't');
ve  = bmMitosius_load(allLinesBinningspath, 've');

reader = createRawDataReader(brainScanFile, false);
p = reader.acquisitionParams;
% Adjust grid size for coil sensitivity maps
FoV = p.FoV;  % Field of View
matrix_size = FoV / 3;  % Max nominal spatial resolution
N_u = [matrix_size, matrix_size, matrix_size];
n_u = N_u;
dK_u = [1, 1, 1] / FoV;



load(coilSensitivityPath)
C = bmImResize(C, [48, 48, 48], N_u);
%% Regridded reconstruction: Mathilda
x0 = bmMathilda(y{1}, t{1}, ve{1}, C, N_u, n_u, dK_u, [], [], [], []);
bmImage(x0)

y   = bmMitosius_load(seqBinningspath, 'y');
t   = bmMitosius_load(seqBinningspath, 't');
ve  = bmMitosius_load(seqBinningspath, 've');

nFr = size(y,1);
% To speed things up limit the nFr to 8
nFr = 8;
x1 = cell(nFr, 1);
for i = 1:nFr
    x1{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
end
bmImage(x1)

%% Iterative Sense reconstruction: Sensa
[Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);
nIter = 30; % Number
witness_ind = [];
nCGD      = 4;
ve_max    = 10*prod(dK_u(:));

x_sensa = cell(nFr, 1);
for i = 1:nFr

    nIter       = 30; % Stop after 30 iterations
    witness_ind = 1:3:nIter; % Only track one out of three steps
    witnessInfo = bmWitnessInfo(['sensa_frame_', num2str(i)], witness_ind);
    ve_max  = 10*prod(dK_u(:));

    x_sensa{i} = bmSensa( x1{i}, y{i}, ve{i}, C, Gu{i}, Gut{i}, n_u, nCGD, ve_max,nIter, witnessInfo);
end
bmImage(x_sensa)

%% Compressed Sensing reconstruction: 
[Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);
nIter = 30; % Number
witness_ind = [];
delta     = 0.1;
rho       = 10*delta;
witness_ind = 1:3:nIter; % Only track one out of three steps
nCGD    = 4;

x_cs = bmTevaMorphosia_chain(  x1, ...
                            [], [], ...
                            y(1:nFr), ve(1:nFr), C, ...
                            Gu, Gut, n_u, ...
                            [], [], ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            nIter, ...
                            bmWitnessInfo('tevaMorphosia_d0p1_r1_nCGD4', witness_ind));

bmImage(x_cs);

%% This reconstruction step could require high computing resources
% depending on the parameters. If you encounter an Out-Of-Memory error (OOM), 
% be aware that the RAM bottleneck is within the fft algorithm, so the only
% way to overcome this are:
% 1. Reduce the virtual cartesian grid size (=Number of reconstructed pixels)
% 2. Increase the computational resources