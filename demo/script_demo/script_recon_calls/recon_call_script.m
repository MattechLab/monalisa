%% Setting Path and loading Data

% Find the Monalisa directory 
[monalisa_dir, ~, ~] = fileparts(  matlab.desktop.editor.getActiveFilename  ); 
for i = 1:3
    [monalisa_dir, ~, ~] = fileparts(monalisa_dir); 
end

% Add the paths to all Monalisa subdirectories : 
addpath(genpath(monalisa_dir));

% Load 1 of the 3 demonstration dataset: 
load([  monalisa_dir, filesep, ...
        'demo', filesep, ...
        'data_demo', filesep, ...
        'data_cardiac_CINE_radial_simulated_from_XCAT', filesep, ...
        'data.mat']); 
%
%    
% load([  monalisa_dir, filesep, ...
%         'demo', filesep, ...
%         'data_demo', filesep, ...
%         'data_cardiac_CINE_radial_simulated_from_cartesian', filesep, ...
%         'data.mat']); 
% 
% 
% load([  monalisa_dir, filesep, ...
%         'demo', filesep, ...
%         'data_demo', filesep, ...
%         'data_cardiac_CINE_radial_measured', filesep, ...
%         'data.mat']); 
 



% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Of note : the results of iterative reconstrucitons will automatically be
% saved in the current directory. Please set you current directory so that
% files can be written in it. 
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

% As an example, we set here the 'temp' directory of the Monalisa 
% directory as current directory: 
cd([monalisa_dir, filesep, 'temp']); 





%% volume_elements: From the trajectory t we compute ve (volume elements)

% This depends only on the trajectory. There is a function
% bmVolumeElement_xxxxxx for each type of trajectory. For special
% trajectories you may have to implement your own volume-element function. 
% In the present case, we have a 2D radial trajectory. 

% t is a cell-array of size nFr x 1, containing double-precission 
% arrays of dimension frDim x nPt{i}. 

ve = bmVolumeElement(t, 'voronoi_full_radial2'); 
% the result of this function are the volume elements, that is still 
% a nFr x 1 cell array, containing values of dimension 1 x nPt{i} doubles


%% Mathilda

% This is our gridded zero-padded reconstruction for non-cartesian data. 
% Mathilda does the same as Nasha mathematically, 
% but without computing any gridding matrix. 
% 
% Mathilda is a single-frame reconstruciton. We call it here for each 
% data-bin independnetly. 


x0 = cell(nFr, 1);
for i = 1:nFr
    x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, frSize, dK_u, [], [], [], []);
end
bmImage(x0);

%% gridding_matrices

% The sparse matrices computed here are the gridding matrices for
% non-cartesain reconstructions. They depend on the trajectory, FoV 
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

for i = 1:nFr
    x0{i} = bmNasha(y{i}, Gn{i}, frSize, C, []);
end
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

% Here is the code to call Sensa for a single frame: 
    
nIter         = 30;
nCGD          = 4;
witness_ind   = [1, nIter];
witness_label = 'sensa_frame_1';
witnessInfo   = bmWitnessInfo(witness_label, witness_ind);
ve_max        = 10*prod(dK_u(:));

x   = bmSensa(  x0{1}, y{1}, ve{1}, C, Gu{1}, Gut{1}, frSize,...
                nCGD, ve_max, ...
                nIter, witnessInfo);

            
            
%%
% Here is the code to call Sensa for each frame independently: 

x = cell(nFr, 1); 
for i = 1:nFr
    
    nIter         = 30;
    nCGD          = 4;
    witness_ind   = [1, nIter];
    witness_label = ['sensa_frame_', num2str(i)]; 
    witnessInfo   = bmWitnessInfo(witness_label, witness_ind);
    ve_max        = 10*prod(dK_u(:));
        
    x{i} = bmSensa( x0{i}, y{i}, ve{i}, C, Gu{i}, Gut{i}, frSize,...
                    nCGD, ve_max, ...
                    nIter, witnessInfo);
end

bmImage(x)

%% Steva

% This is a least-square regularized reconstruction for non-cartesian data,
% where the regularization is the l1-norm of the spatial gradient of the
% image. 
% It is a single-frame reconstruction that consists of minimizing the
% objective function with the ADMM algorithm. 
% Delta is the regularization weight. Parameter rho is the convergence 
% parameter. 
%
% Here is the code to call Steva for a single frame: 


nIter         = 30;
nCGD          = 4;
witness_ind   = [1, nIter];
witness_label = 'steva_frame_1';
witnessInfo   = bmWitnessInfo(witness_label, witness_ind);
ve_max        = 10*prod(dK_u(:));

delta         = 1; 
rho           = 10*delta;  

x             = bmSteva(    x0{1}, [], [], y{1}, ve{1}, C, Gu{1}, Gut{1}, frSize, ...
                            delta, rho, nCGD, ve_max, ...
                            nIter, witnessInfo); 

bmImage(x); 

%%
% Here is the code to call Steva for each frame independently: 

x = cell(nFr, 1); 
for i = 1:nFr
    
    nIter         = 30;
    nCGD          = 4;
    witness_ind   = [1, nIter];
    witness_label = ['steva_frame_', num2str(i)];
    witnessInfo   = bmWitnessInfo(witness_label, witness_ind);
    ve_max        = 10*prod(dK_u(:));
        
    x{i}          = bmSteva(    x0{i}, [], [], y{i}, ve{i}, C, Gu{i}, Gut{i}, frSize, ...
                            delta, rho, nCGD, ve_max, ...
                            nIter, witnessInfo); 
                        
end

bmImage(x)


%% Sleva

% This is a least-square regularized reconstruction for non-cartesian data,
% where the regularization is the l2-norm of the image. 
% It is a single-frame reconstruction that consists in minimizing the
% objective function with the conjugate gradient descent method. 
% Delta is the regularization weight.
%
% Here is the code to call Sleva for a single frame: 


nIter         = 30;
nCGD          = 4;
witness_ind   = [1, nIter];
witness_label = 'sleva_frame_1';
witnessInfo   = bmWitnessInfo(witness_label, witness_ind);
ve_max        = 10*prod(dK_u(:));

delta         = 1; 

x             = bmSleva(x0{1}, ...
                        y{1}, ve{1}, C, ...
                        Gu{1}, Gut{1}, frSize, ...
                        delta, 'normal', ...
                        nCGD, ve_max, ...
                        nIter, witnessInfo  ); 

bmImage(x); 

%%
% Here is the code to call Sleva for each frame independently: 

x = cell(nFr, 1); 
for i = 1:nFr
    
    nIter         = 30;
    nCGD          = 4;
    witness_ind   = [1, nIter];
    witness_label = ['sleva_frame_', num2str(i)];
    witnessInfo   = bmWitnessInfo(witness_label, witness_ind);
    ve_max        = 10*prod(dK_u(:));
        
    x{i}          = bmSleva(x0{i}, ...
                            y{i}, ve{i}, C, ...
                            Gu{i}, Gut{i}, frSize, ...
                            delta, 'normal', ...
                            nCGD, ve_max, ...
                            nIter, witnessInfo  ); 
                        
end

bmImage(x)




%% TevaMorphosia_chain without deformation-fields

% TevaMorphosia_chain can be called with or without deformation matrices.
% We call it here without. 
%
% It is then a least-square regularized reconstruction for non-cartesian 
% data, where the regularization is the l1-norm temporal derivative of the 
% image. It is a multiple-frame reconstruction that consists in minimizing 
% the objective function with the ADMM algorithm. 
%
% Delta is the regularization weight and rho is the convergence parmeter. 

nIter         = 30;
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

%% tevaDuoMorphosia_chain

nIter         = 30;
witness_ind   = [];
witness_label = 'tevaMorphosia_d0p1_r1_nCGD4';
delta         = 0.1;
rho           = 10*delta;
nCGD          = 4;
ve_max        = 10*prod(dK_u(:));

x = bmTevaDuoMorphosia_chain(   x0, ...
                                [], [], [], [], ...
                                y, ve, C, ...
                                Gu, Gut, n_u, ...
                                [], [], [], [], ...
                                delta, rho, 'normal', ...
                                nCGD, ve_max, ...
                                bmConvergeCondition(nIter), ...
                                bmWitnessInfo(witness_label, witness_ind));

bmImage(x)

%% deform_field evaluation with imReg Demon 

reg_file                        = 'C:\main\temp\demo_sion\reg_file';
[DF_to_prev, imReg_to_prev]     = bmImDeformFieldChain_imRegDemons23(  h, n_u, 'curr_to_prev', 500, 1, reg_file, reg_mask); 
[DF_to_next, imReg_to_next]     = bmImDeformFieldChain_imRegDemons23(  h, n_u, 'curr_to_next', 500, 1, reg_file, reg_mask); 

%% Evaluation of the deformation-matrices

% Multipying an image-vector x by the (sparse) matrix Tu results in a new
% image-vector which is the deformation of x by the deformatio-field
% encoded in Tu. Matrix Tut is the transposed matrix of Tu. 

[Tu1, Tu1t] = bmImDeformField2SparseMat(DF_to_prev, N_u, [], true);
[Tu2, Tu2t] = bmImDeformField2SparseMat(DF_to_next, N_u, [], true);

%% tevaMorphosia with deformField

nIter         = 30;
witness_ind   = [];
witness_label = 'tevaMorphosia_d0p5_r5_nCGD4';
delta         = 0.5;
rho           = 10*delta;
nCGD          = 4;
ve_max        = 10*prod(dK_u(:));

x = bmTevaMorphosia_chain(  x0, ...
                            [], [], ...
                            y, ve, C, ...
                            Gu, Gut, n_u, ...
                            Tu1, Tu1t, ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            bmConvergeCondition(nIter), ...
                            bmWitnessInfo(witness_label, witness_ind));

bmImage(x)

%% tevaDuoMorphosia with deformField

nIter         = 30;
witness_ind   = [];
witness_label = 'tevaMorphosia_d0p5_r5_nCGD4';
delta         = 0.5;
rho           = 10*delta;
nCGD          = 4;
ve_max        = 10*prod(dK_u(:));

x = bmTevaDuoMorphosia_chain(   x0, ...
                                [], [], [], [], ...
                                y, ve, C, ...
                                Gu, Gut, n_u, ...
                                Tu1, Tu1t, Tu2, Tu2t, ...
                                delta, rho, 'normal', ...
                                nCGD, ve_max, ...
                                bmConvergeCondition(nIter), ...
                                bmWitnessInfo(witness_label, witness_ind));

bmImage(x)
