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

% demo_data_7 -------------------------------------------------------------
load([  monalisa_dir, filesep, ...
        'demo', filesep, ...
        'data_demo', filesep, ...
        'data_7_sheet_radial_simulated_from_XCAT', filesep, ...
        'data.mat']); 
    
% This dataset was simulated with the XCAT phantom. 
%
% W. P. Segars, G. Sturgeon, S. Mendonca, J. Grimes, and B. M. W. Tsui, 
% ‘4D XCAT phantom for multimodality imaging research’, 
% Med. Phys., vol. 37, no. 9, Art. no. 9, Sep. 2010, 
% doi: 10.1118/1.3480985.
%     
% END_demo_data_7 ---------------------------------------------------------


%% Chosing the current directory

% The results of iterative reconstrucitons will automatically be
% saved in the current directory. Please set you current directory so that
% files can be written in it. 

% As an example, we set here the 'temp' directory of the Monalisa 
% directory as current directory: 

if ~bmCheckDir([monalisa_dir, filesep, 'temp'], false)
   bmCreateDir([monalisa_dir, filesep, 'temp']);  
end
cd([monalisa_dir, filesep, 'temp']); 





%% volume_elements: From the trajectory t we compute volume elements ve.

% This depends only on the trajectory. There is a function
% bmVolumeElement_xxxxxx for each type of trajectory. For special
% trajectories you may have to implement your own volume-element function. 
% In the present case, we have a 2D radial trajectory. 

% For chain reconstructions is t a cell-array of size nFr x 1 where nFr is
% the number of frames in the chain. Cell number i contains a 
% double-precission array of size [frDim, nPt{i}] where nPt{i} is the 
% number of points in the trajectory of bin number i. 
% The result ve is then an nFr x 1 cell array, each cell containing a 
% double precision array of dimension 1 x nPt{i}.

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
% Mathilda is a single-frame reconstruciton. We call it here for each 
% data-bin independnetly. 


x0 = cell(nCard, nResp);
for i = 1:nCard
    for j = 1:nResp
        x0{i, j} = bmMathilda(y{i, j}, t{i, j}, ve{i, j}, C, N_u, frSize, dK_u, [], [], [], []);
    end
end

% Use the arrows to run through different frames in the displayed image. 
bmImage(x0);

%% Gridding Matrices

% The sparse matrices computed here are the gridding matrices for
% non-cartesain reconstructions. They depend on the trajectory, 
% reconstruction FoV (dK_u) and grid-size N_u. 
%
% Gu is the forward-gridding matrix and Gut is its transposed matrix. 
% Gn is the inverse griddoing matrix. 

[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);


%% TevaMorphosia_sheet without deformation matrices

% TevaMorphosia_sheet can be called with or without deformation matrices.
% We call it here without. 
%
% Without defomation matrices, it is a least-square regularized 
% reconstruction for non-cartesian data, where the regularization
% is the sum of the l1-norm of the derivative along the first non-spatial
% dimension and the l1-norm of the derivative along the second non-spatial
% dimension. 
%
% It is a multiple-frame reconstruction that consists in minimizing 
% the objective function with the ADMM algorithm. 
%
% Delta is the regularization weight and Rho is the convergence parameter 
% of ADMM. 

nIter               = 30;
witness_ind         = 1:5:nIter; 
witness_label       = 'tevaMorphosia_sheet_d0p1_r1_nCGD4';
save_witnessIm_flag = true;
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);

delta               = 0.1;
rho                 = 10*delta;
nCGD                = 4;
ve_max              = 10*prod(dK_u(:));

x = bmTevaMorphosia_sheet(  x0, ...
                            [], [], [], [],...
                            y, ve, C, ...
                            Gu, Gut, frSize, ...
                            [], [], [], [], ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            nIter, ...
                            witnessInfo);                        
                               

bmImage(x)
x1 = x; 



%% Deformation-Fields Estimation

% The next reconstruction functions can be run with or without
% deformation matrices. In order to test both cases, we already estimate 
% here the deformation-fiels for later usage. 
%
% In this example, the deformation-fields are estimated with the
% imregdemons function of matlab, but the user can use any other 
% appropriate method. 

nIter                           = [500, 500]; 
maxPixDisp                      = 10; 
nSmoothing                      = 1; 

[DF_to_prev_1, DF_to_prev_2]     = bmImDeformFieldSheet_imRegDemons23(  x1, frSize, 'curr_to_prev', nIter, nSmoothing, [], reg_mask, maxPixDisp); 


%% Evaluation of the deformation-matrices

% Multipying an image-vector x by the (sparse) matrix Tu results in a new
% image-vector which is the deformation of x by the deformatio-field
% encoded in Tu. Matrix Tut is the transposed matrix of Tu. 

[Tu1, Tu1t] = bmImDeformField2SparseMat(DF_to_prev_1, N_u, [], true);
[Tu2, Tu2t] = bmImDeformField2SparseMat(DF_to_prev_2, N_u, [], true);


%% TevaMorphosia_sheet with deformation matrices

% TevaMorphosia_sheet can be called with or without deformation matrices.
% We include it here. 
%
% With defomation matrices, it is a least-square regularized 
% reconstruction for non-cartesian data, where the regularization
% is the l1-norm of the motion-compensated differences between 
% neighboring frames along the two non-spatial dimensiont. 
% 
% It is a multiple-frame reconstruction that consists in minimizing 
% the objective function with the ADMM algorithm. 
%
% Delta is the regularization weight and Rho is the convergence parameter 
% of ADMM. 

nIter               = 30;
witness_ind         = 1:5:nIter;
witness_label       = 'tevaMorphosia_sheet_d0p3_r3_nCGD4_DF';
save_witnessIm_flag = true; 
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);

delta               = 0.3;
rho                 = 10*delta;
nCGD                = 4;
ve_max              = 10*prod(dK_u(:));

x = bmTevaMorphosia_sheet(  x0, ...
                            [], [], [], [], ...
                            y, ve, C, ...
                            Gu, Gut, frSize, ...
                            Tu1, Tu1t, Tu2, Tu2t, ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            nIter, ...
                            witnessInfo);

bmImage(x)



%% SensitivaMorphosia_sheet without deformation matrices

% SensitivaMorphosia_sheet can be called with or without 
% deformation matrices. We call it here without. 
%
% It is then a least-square regularized reconstruction for non-cartesian 
% data, where the regularization is the squared l2-norm of the 
% derivatives of the image along the two non-spatial dimensions. 
%
% It is a multiple-frame reconstruction 
% that consists in minimizing the objective function 
% with the conjugate gradient descent method. 
%
% Delta is the regularization weight. 

nIter               = 30;
witness_ind         = 1:5:nIter;
witness_label       = 'sensitivaMorphosia_sheet_d3_nCGD4';
save_witnessIm_flag = true;
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);

delta         = 3;
nCGD          = 4;
ve_max        = 10*prod(dK_u(:));

x = bmSensitivaMorphosia_sheet( x0, ...
                                y, ve, C, ...
                                Gu, Gut, frSize, ...
                                [], [], [], [],...
                                delta, 'normal', ...
                                nCGD, ve_max, ...
                                nIter, ...
                                witnessInfo);

bmImage(x)


%% SensitivaMorphosia_sheet with deformation matrices

% SensitivaMorphosia_sheet can be called with or without 
% deformation matrices. We include it here . 
%
% It is then a least-square regularized reconstruction for non-cartesian 
% data, where the regularization is the squared l2-norm of the motion
% compensated difference between neighboring frames along the two 
% non-spatial dimensions.  
% 
% It is a multiple-frame reconstruction 
% that consists in minimizing the objective function 
% with the conjugate gradient descent method. 
%
% Delta is the regularization weight. 

nIter               = 30;
witness_ind         = [];
witness_label       = 'sensitivaMorphosia_sheet_d3_nCGD4_DF';
save_witnessIm_flag = true;
witnessInfo         = bmWitnessInfo(witness_label, witness_ind, save_witnessIm_flag);

delta               = 3;
nCGD                = 4;
ve_max              = 10*prod(dK_u(:));

x = bmSensitivaMorphosia_chain( x0, ...
                                y, ve, C, ...
                                Gu, Gut, frSize, ...
                                Tu1, Tu1t, Tu2, Tu2t, ...
                                delta, 'normal', ...
                                nCGD, ve_max, ...
                                nIter, ...
                                witnessInfo);

bmImage(x)
