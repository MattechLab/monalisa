%% Setting Path and loading Data

% Specify here the path to the monalisa directory : 
monalisa_dir = 'C:\main\project\monalisa_git_project\monalisa'; 
addpath(genpath(monalisa_dir));

% Load some demonstration-data 
load([monalisa_dir, '\demo\data_demo\data_cardiac_CINE_radial_simulated_from_XCAT\data.mat']); 



% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% Of note : the results of iterative reconstrucitons will automatically be
% saved in the current directory. Please set you current directory so that
% files can be written in it. 
% !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



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

%% gridding_matrices

% This depends on the trajectory, FoV and matrix-size (N_u). 

[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

%% Mathilda

% This is the gridded recon for any non-cartesian data-set.
% Mathilda does the same as Nasha mathematically, but without computing 
% the Gn, which takes a lot of time.
% 
% 
% Mathilda is a single-frame reconstruciton. We call it here for each 
% data-bin independnetly. 


x0 = cell(nFr, 1);
for i = 1:nFr
    x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, frSize, dK_u, [], [], [], []);
end
bmImage(x0);

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

% This is the iterative-SENSE reconstruction for non-cartesian data. 
% It is a per-frame recon. There is no sharing of information 
% between frame. Theresult is therefore very bad for very undersampled 
% data. But this recon is important because it has a very 
% important geometrical meaning in the theory of reconstruction 
% and it has some application for some special
% cases. 

x = cell(nFr, 1); 
for i = 1:nFr
    
    nIter         = 30;
    nCGD          = 4;
    witness_ind   = [1, nIter];
    witness_label = 'sensa_frame_';
    witnessInfo   = bmWitnessInfo([witness_label, num2str(i)], witness_ind);
    ve_max        = 10*prod(dK_u(:));
        
    x{i} = bmSensa( x0{i}, y{i}, ve{i}, C, Gu{i}, Gut{i}, frSize,...
                    nCGD, ve_max, ...
                    nIter, witnessInfo);
end

bmImage(x)

%% Steva

%% Sleva


%% tevaMorphosia_no_deformField

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

%% tevaDuoMorphosia_no_deformField

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

[Tu1, Tu1t] = bmImDeformField2SparseMat(DF_to_prev, N_u, [], true);
[Tu2, Tu2t] = bmImDeformField2SparseMat(DF_to_next, N_u, [], true);

%% tevaMorphosia_with_deformField

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

%% tevaDuoMorphosia_with_deformField

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
