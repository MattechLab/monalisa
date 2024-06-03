% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmSensitivaMorphosia_chain(x, ...
                                  y, ve, C, ...
                                  Gu, Gut, n_u, ...
                                  Tu, Tut, ...
                                  delta, regul_mode, ...
                                  nCGD, ve_max, ...
                                  convCond, witnessInfo  )

% initial -----------------------------------------------------------------

% function_label
function_label = 'sensitivaMorphosia'; 

disp([function_label, ' initial...']); 

% magic_numbers
myEps                   = 10*eps('single'); % -------------------------------- magic number


% input data and output image are single. 
x                       = bmSingle(bmColReshape(x, n_u));
y                       = bmSingle(y);



% every size is double (because indices must be double in Matlab)
nCh                     = double(size(y{1}, 2));
nFr                     = double(size(y(:), 1));
N_u                     = double(int32(Gu{1}.N_u(:)'));
n_u                     = double(int32(n_u(:)'));
nPt_u                   = double(prod(n_u(:)));



% every phsysical quantity is single
dK_u                    = single(   Gu{1}.d_u(:)'   );
dX_u                    = single(  (1./single(dK_u))./single(N_u)  );
HX                      = single(  prod(dX_u(:))  );
HZ                      = single(HX); 
HY                      = private_ve_to_HY(ve, ve_max, y); 



% algorithm parameters are single 
delta_list              = single(private_init_regul_param(delta,   convCond.nIter_max)); 



% coil_sense and deapodization kernels are single
C                       = single(bmBlockReshape(C, n_u));
KFC                     = single(bmKF(          C,  N_u, n_u, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));
KFC_conj                = single(bmKF_conj(conj(C), N_u, n_u, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));



% initialize Tu's and Tut's
if isempty(Tu)
    Tu = cell(nFr, 1); 
end
if isempty(Tut)
    Tut = cell(nFr, 1); 
end


% debluring kernel for deformations (we leave it empty ,so no effect). 
K_bump          = []; % bmK_bump(N_u).^(0.5); 


bmInitialWitnessInfo(   witnessInfo, ...
                        function_label, ...
                        N_u, n_u, dK_u, ve_max, ...
                        convCond.nIter_max, ...
                        nCGD, ...
                        delta_list, [], ...
                        regul_mode); 
                    
[dafi, regul] = private_dafi_regul(x, y, Gu, Tu, HY, HZ, n_u, nFr, KFC, K_bump);

disp('... initial done. ');
% END_initial -------------------------------------------------------------



% ADMM loop ---------------------------------------------------------------
disp([function_label, ' is running ...']);
while convCond.check()
    
    c       = convCond.nIter_curr; 
    
    % seting_regul_weight -------------------------------------------------
    if strcmp(regul_mode, 'normal')
        delta       = delta_list(1, c);
    elseif strcmp(regul_mode, 'adapt')
        delta       = private_adapt_delta(dafi, regul, delta_list(1, c)); 
    end
    % END_seting_regul_weight ---------------------------------------------
    
    
    % CGD -----------------------------------------------------------------
    
    % L_Aube
    res_y_next              = bmMinus(  y,  private_M(x, Gu, n_u, nFr, KFC   )      );  
    res_z_next              = bmMinus(  0,  private_F(x, Tu, n_u, nFr, K_bump)    );
    dagM_res_y_next         = private_dagM(res_y_next, Gut, HX, HY, n_u, nFr, KFC_conj);
    dagF_res_z_next       = bmMult(delta, private_dagF(res_z_next, Tut, HX, HZ, n_u, nFr, K_bump));
    dagA_res_next           = bmPlus(dagM_res_y_next, dagF_res_z_next); 
    p_next                  = dagA_res_next; 
    sqn_dagA_res_next       = bmSquaredNorm(  dagA_res_next, HX  ); 
    
    
    for j = 1:nCGD
        
        % Le_Matin
        res_y_curr          = res_y_next;
        res_z_curr          = res_z_next;
        sqn_dagA_res_curr   = sqn_dagA_res_next; 
        p_curr              = p_next;
        if(sqn_dagA_res_curr < myEps)
            break;
        end
        
        % Le_Midi
        Mp_curr             = private_M(p_curr, Gu, n_u, nFr, KFC); 
        Fp_curr             = private_F(p_curr, Tu, n_u, nFr, K_bump); 
        sqn_Mp_curr         = bmSquaredNorm(Mp_curr, HY); 
        sqn_Fp_curr         = bmSquaredNorm(Fp_curr, delta*HZ);
        sqn_Ap_curr         = sqn_Mp_curr + sqn_Fp_curr;
        
        
        % Le_Soir
        a                   = sqn_dagA_res_curr/sqn_Ap_curr;
        x                   = bmAxpy(a, p_curr, x); 
        if j == nCGD
            break;
        end
        
        
        % La_Nouvelle_Aube
        res_y_next          = bmAxpy(-a, Mp_curr, res_y_curr); 
        res_z_next          = bmAxpy(-a, Fp_curr, res_z_curr);
        dagM_res_y_next     =               private_dagM(res_y_next, Gut, HX, HY, n_u, nFr, KFC_conj);
        dagF_res_z_next     = bmMult(delta, private_dagF(res_z_next, Tut, HX, HZ, n_u, nFr, K_bump));
        dagA_res_next       = bmPlus(dagM_res_y_next, dagF_res_z_next); 
        sqn_dagA_res_next   = bmSquaredNorm(dagA_res_next, HX);
        b                   = sqn_dagA_res_next/sqn_dagA_res_curr; 
        p_next              = bmAxpy(b, p_curr, dagA_res_next); 
        
    end
    % END_CGD -------------------------------------------------------------
    
     
    
    % monitoring ----------------------------------------------------------
    [dafi, regul]                   = private_dafi_regul(x, y, Gu, Tu, HY, HZ, n_u, nFr, KFC, K_bump);
    
    objective                       = 0.5*dafi + 0.5*delta*regul; 
    witnessInfo.param{11}(1, c)     = objective; 
    witnessInfo.param{12}(1, c)     = dafi;  
    witnessInfo.param{13}(1, c)     = regul; 
    witnessInfo.watch(c, x, n_u, 'loop');
    % END_monitoring ------------------------------------------------------
    
end
disp(['... ', function_label, ' completed. '])
% END_ADMM loop -----------------------------------------------------------




% final -------------------------------------------------------------------
witnessInfo.watch(convCond.nIter_curr, x, n_u, 'final');
x = bmBlockReshape(x, n_u);
% END_final ---------------------------------------------------------------

end




% HELP_FUNCIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function HY = private_ve_to_HY(ve, ve_max, y)
    nFr = size(y(:), 1);
    HY  = cell(nFr, 1); 
    for i = 1:nFr
        ve{i}               = single(bmY_ve_reshape(ve{i},  size(y{i})  ));
        HY{i}               = min(ve{i}, single(ve_max)); % Important, we limit the value of ve.
    end
end



function [dafi, regul]    = private_dafi_regul(x, y, Gu, Tu, HY, HZ, n_u, nFr, KFC, K_bump) 

    dafi   = 0;
    regul  = 0; 
    for i = 1:nFr
        temp_res    = y{i} - bmShanna(x{i}, Gu{i}, KFC, n_u, 'MATLAB'); % residu
        dafi        = dafi + bmSquaredNorm(temp_res, HY{i});   
        
        i_minus_1   = mod( (i-1) - 1, nFr) + 1; 
        temp_res    = x{i_minus_1} - bmImDeform(Tu{i}, x{i}, n_u, K_bump);
        regul       = regul + bmSquaredNorm(temp_res, HZ);      

    end 
end


function out_param = private_init_regul_param(in_param, nIter_max)

out_param       = single(  abs(in_param(:))  );
if size(out_param, 1) == 1
    out_param   = linspace(out_param, out_param, nIter_max);
elseif size(out_param, 1) == 2
    out_param   = linspace(out_param(1, 1), out_param(2, 1), nIter_max);
end
out_param = out_param(:)';
out_param = single(out_param); 

end


function delta = private_adapt_delta(dafi, regul, delta_factor)

delta   = delta_factor*regul/dafi;   

end
% END_HELP_FUNCIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







% MODEL_AND_SPARSIFIER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% forward_model
function M_x = private_M(x, Gu, n_u, nFr, KFC)
    M_x = cell(nFr, 1); 
    for i = 1:nFr
        M_x{i}     = bmShanna(x{i}, Gu{i}, KFC, n_u, 'MATLAB');
    end
end


% forward_sparsifier
function F_x = private_F(x, Tu, n_u, nFr, K_bump)
    F_x = cell(nFr, 1); 
    for i = 1:nFr
        i_minus_1   = mod( (i-1) - 1, nFr) + 1;
        F_x{i}     = bmImDeform(Tu{i}, x{i}, n_u, K_bump) - x{i_minus_1}; 
    end
end



% adjoint_model
function dagM_y = private_dagM(y, Gut, HX, HY, n_u, nFr, KFC_conj)
    dagM_y = cell(nFr, 1); 
    for i = 1:nFr
        dagM_y{i} = (1/HX)*bmNakatsha(HY{i}.*y{i}, Gut{i}, KFC_conj, true, n_u, 'MATLAB'); % negative_gradient
    end
end


% adjoint_sparsifier
function dagF_z = private_dagF(z, Tut, HX, HZ, n_u, nFr, K_bump)
    dagF_z = cell(nFr, 1); 
    for i = 1:nFr
        i_plus_1   = mod( (i+1) - 1, nFr) + 1;
        dagF_z{i} = (1/HX)*(   bmImDeformT(Tut{i}, HZ*z{i}, n_u, K_bump) - HZ*z{i_plus_1}  ); % negative_gradient
    end
end

% END_MODEL_AND_SPARSIFIER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

