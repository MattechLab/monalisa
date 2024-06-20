%% volume_elements

% This depends only on the trajectory. There is a function
% bmVolumeElement_blablabla for each type of trajectory. For special
% trejectories you may have to implement your own volumeElement,function. 
% In the present case, we have a 2D radial trajectory. 

ve = bmVolumeElement(t, 'voronoi_full_radial2'); 

%% gridding_matrices

% This depends on the trajectory, FoV and matrix-size (N_u). 

[Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);

%% KFC and KFC_conj

KFC         = bmKF(C,               N_u, n_u, dK_u, nCh);
KFC_conj    = bmKF_conj(conj(C),    N_u, n_u, dK_u, nCh);


%% Mathilda_per_cell

% This is the gridded recon for any non-cartesian data-set. 

x0 = cell(nFr, 1);
for i = 1:nFr
    x0{i} = bmMathilda(y{i}, t{i}, ve{i}, C, N_u, n_u, dK_u, [], [], [], []);
end
bmImage(x0);

%% Nasha

% It performs the same like Mathilda, but with gridding matrix Gn. We never
% use Nasha, excepted if we have to repeat the exact same gridded recon 
% manytimes. But it is rarely the case. A gridded recon is usually done 
% only one time for one data set. We use therefore Mathilda. 

for i = 1:nFr
    x0{i} = bmNasha(y{i}, Gn{i}, n_u, C, []);
end
bmImage(x0);

%% Sensa

% This is the iterative-SENSE recon for non-cartesian data. It is a
% per-frame recon. There is no sharing of information between frame. The
% result is therefore very bad for very undersampled data. But this recon
% is important because it has a very important geometrical meaning in the
% theory of reconstruction and it has some application for some special
% cases. I have put a demo of reconstruciton here for the sake of
% completeness. 


x = cell(nFr, 1); 
for i = 1:nFr
    
    nIter       = 30;
    witness_ind = []; % 1:nIter;
    witnessInfo = bmWitnessInfo(['sensa_frame_', num2str(i)], witness_ind);
    convCond    = bmConvergeCondition(nIter);
    
    nCGD    = 4;
    ve_max  = 10*prod(dK_u(:));
    
    
    x{i} = bmSensa( x0{i}, y{i}, ve{i}, C, Gu{i}, Gut{i}, n_u,...
                    nCGD, ve_max, ...
                    convCond, witnessInfo);
end

bmImage(x)

%% tevaMorphosia_no_deformField

nIter = 30;
witness_ind = [];

delta     = 0.1;
rho       = 10*delta;
nCGD      = 4;
ve_max    = 10*prod(dK_u(:));

x = bmTevaMorphosia_chain(  x0, ...
                            [], [], ...
                            y, ve, C, ...
                            Gu, Gut, n_u, ...
                            [], [], ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            bmConvergeCondition(nIter), ...
                            bmWitnessInfo('tevaMorphosia_d0p1_r1_nCGD4', witness_ind));

bmImage(x)




%% tevaDuoMorphosia_no_deformField

nIter = 30;
witness_ind = [];

delta     = 0.1;
rho       = 10*delta;
nCGD      = 4;
ve_max    = 10*prod(dK_u(:));

x = bmTevaDuoMorphosia_chain(   x0, ...
                                [], [], [], [], ...
                                y, ve, C, ...
                                Gu, Gut, n_u, ...
                                [], [], [], [], ...
                                delta, rho, 'normal', ...
                                nCGD, ve_max, ...
                                bmConvergeCondition(nIter), ...
                                bmWitnessInfo('tevaMorphosia_d0p1_r1_nCGD4', witness_ind));

bmImage(x)






%% deform_field evaluation with imReg Demon 
reg_file                        = 'C:\main\temp\demo_sion\reg_file';
[DF_to_prev, imReg_to_prev]     = bmImDeformFieldChain_imRegDemons23(  h, n_u, 'curr_to_prev', 500, 1, reg_file, reg_mask); 
[DF_to_next, imReg_to_next]     = bmImDeformFieldChain_imRegDemons23(  h, n_u, 'curr_to_next', 500, 1, reg_file, reg_mask); 


%%

[Tu1, Tu1t] = bmImDeformField2SparseMat(DF_to_prev, N_u, [], true);
[Tu2, Tu2t] = bmImDeformField2SparseMat(DF_to_next, N_u, [], true);

%% tevaMorphosia_with_deformField

nIter = 30;
witness_ind = [];

delta     = 0.5;
rho       = 10*delta;
nCGD      = 4;
ve_max    = 10*prod(dK_u(:));

x = bmTevaMorphosia_chain(  x0, ...
                            [], [], ...
                            y, ve, C, ...
                            Gu, Gut, n_u, ...
                            Tu1, Tu1t, ...
                            delta, rho, 'normal', ...
                            nCGD, ve_max, ...
                            bmConvergeCondition(nIter), ...
                            bmWitnessInfo('tevaMorphosia_d0p5_r5_nCGD4', witness_ind));

bmImage(x)



%% tevaDuoMorphosia_with_deformField

nIter = 30;
witness_ind = [];

delta     = 0.5;
rho       = 10*delta;
nCGD      = 4;
ve_max    = 10*prod(dK_u(:));

x = bmTevaDuoMorphosia_chain(   x0, ...
                                [], [], [], [], ...
                                y, ve, C, ...
                                Gu, Gut, n_u, ...
                                Tu1, Tu1t, Tu2, Tu2t, ...
                                delta, rho, 'normal', ...
                                nCGD, ve_max, ...
                                bmConvergeCondition(nIter), ...
                                bmWitnessInfo('tevaMorphosia_d0p5_r5_nCGD4', witness_ind));

bmImage(x)


