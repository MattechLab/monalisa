% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [x, varargout] = bmTevaDuoMorphosia_chain(x, ...
                                             z1, z2, u1, u2, ... 
                                             y, ve, C, ...
                                             Gu, Gut, frSize, ...
                                             Tu1, Tu1t, Tu2, Tu2t, ...
                                             delta, rho, regul_mode, ...
                                             nCGD, ve_max, ...
                                             nIter, witnessInfo  )

% initial -----------------------------------------------------------------

% function_label
function_label = 'tevaDuoMorphosia'; 

disp([function_label, ' initial...']); 

% magic_numbers
myEps                   = 10*eps('single'); % -------------------------------- magic number


% input data and output image are single. 
x                       = bmSingle(bmColReshape(x, frSize));
y                       = bmSingle(y);



% every size is double (because indices must be double in Matlab)
nCh                     = double(size(y{1}, 2));
nFr                     = double(size(y(:), 1));
N_u                     = double(int32(Gu{1}.N_u(:)'));
frSize                     = double(int32(frSize(:)'));
nPt_u                   = double(prod(frSize(:)));



% every phsysical quantity is single
dK_u                    = single(   Gu{1}.d_u(:)'   );
dX_u                    = single(  (1./single(dK_u))./single(N_u)  );
HX                      = single(  prod(dX_u(:))  );
HZ1                     = single(HX); 
HZ2                     = single(HX); 
HY                      = private_ve_to_HY(ve, ve_max, y); 



% algorithm parameters are single 
delta_list              = single(private_init_regul_param(delta,   nIter)); 
rho_list                = single(private_init_regul_param(rho,     nIter)); 



% coil_sense and deapodization kernels are single
C                       = single(bmBlockReshape(C, frSize));
KFC                     = single(bmKF(          C,  N_u, frSize, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));
KFC_conj                = single(bmKF_conj(conj(C), N_u, frSize, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));



% initialize Tu's and Tut's
if isempty(Tu1)
    Tu1 = cell(nFr, 1); 
end
if isempty(Tu1t)
    Tu1t = cell(nFr, 1); 
end
if isempty(Tu2)
    Tu2 = cell(nFr, 1); 
end
if isempty(Tu2t)
    Tu2t = cell(nFr, 1); 
end

% debluring kernel for deformations (we leave it empty ,so no effect). 
K_bump          = []; % bmK_bump(N_u).^(0.5); 

% initialize z's
if isempty(z1)
    z1   = private_F1(x, Tu1, frSize, nFr, K_bump); 
end
if isempty(z2)
    z2   = private_F2(x, Tu2, frSize, nFr, K_bump); 
end
% initialize u's
if isempty(u1)
    u1   = bmZero([nPt_u, 1], 'complex_single', [nFr, 1]);
end
if isempty(u2)
    u2   = bmZero([nPt_u, 1], 'complex_single', [nFr, 1]);
end

bmInitialWitnessInfo(   witnessInfo, ...
                        function_label, ...
                        N_u, frSize, dK_u, ve_max, ...
                        nIter, ...
                        nCGD, ...
                        delta_list, rho_list, ...
                        regul_mode); 
                    
[dafi, regul] = private_dafi_regul(x, y, Gu, Tu1, Tu2, HY, HZ1, HZ2, frSize, nFr, KFC, K_bump);

disp('... initial done. ');
% END_initial -------------------------------------------------------------



% ADMM loop ---------------------------------------------------------------
disp([function_label, ' is running ...']);
for c = 1:nIter
    
    % seting_regul_weight -------------------------------------------------
    if strcmp(regul_mode, 'normal')
        delta           = delta_list(1, c);
        rho             = rho_list(1, c);
    elseif strcmp(regul_mode, 'adapt')
        [delta, rho]    = private_adapt_delta_rho(dafi, regul, delta_list(1, c), rho_list(1, c)); 
    end
    % END_seting_regul_weight ---------------------------------------------
    
    
    % CGD -----------------------------------------------------------------
    
    % L_Aube
    res_y_next              = bmMinus(                y,  private_M(x, Gu, frSize, nFr, KFC   )      );  
    res_z1_next             = bmMinus(  bmMinus(z1, u1),  private_F1(x, Tu1, frSize, nFr, K_bump)      );
    res_z2_next             = bmMinus(  bmMinus(z2, u2),  private_F2(x, Tu2, frSize, nFr, K_bump)      );
    
    dagM_res_y_next         = private_dagM(res_y_next, Gut, HX, HY, frSize, nFr, KFC_conj);
    
    dagF1_res_z1_next       = bmMult(rho, private_dagF1(res_z1_next, Tu1t, HX, HZ1, frSize, nFr, K_bump));
    dagF2_res_z2_next       = bmMult(rho, private_dagF2(res_z2_next, Tu2t, HX, HZ2, frSize, nFr, K_bump));
    
    
    dagA_res_next           = bmPlus(dagM_res_y_next, bmPlus(dagF1_res_z1_next, dagF2_res_z2_next)); 
    p_next                  = dagA_res_next; 
    sqn_dagA_res_next       = bmSquaredNorm(  dagA_res_next, HX  ); 
    
    
    for j = 1:nCGD
        
        % Le_Matin
        res_y_curr          = res_y_next;
        res_z1_curr         = res_z1_next;
        res_z2_curr         = res_z2_next;
        sqn_dagA_res_curr   = sqn_dagA_res_next; 
        p_curr              = p_next;
        if(sqn_dagA_res_curr < myEps)
            break;
        end
        
        % Le_Midi
        Mp_curr             = private_M(p_curr, Gu, frSize, nFr, KFC); 
        F1p_curr            = private_F1(p_curr, Tu1, frSize, nFr, K_bump); 
        F2p_curr            = private_F2(p_curr, Tu2, frSize, nFr, K_bump); 
        
        sqn_Mp_curr         = bmSquaredNorm(Mp_curr, HY); 
        sqn_F1p_curr        = bmSquaredNorm(F1p_curr, rho*HZ1);
        sqn_F2p_curr        = bmSquaredNorm(F2p_curr, rho*HZ2);
        sqn_Ap_curr         = sqn_Mp_curr + sqn_F1p_curr + sqn_F2p_curr;
        
        
        % Le_Soir
        a                   = sqn_dagA_res_curr/sqn_Ap_curr;
        x                   = bmAxpy(a, p_curr, x); 
        if j == nCGD
            break;
        end
        
        
        % La_Nouvelle_Aube
        res_y_next          = bmAxpy(-a, Mp_curr, res_y_curr); 
        res_z1_next         = bmAxpy(-a, F1p_curr, res_z1_curr);
        res_z2_next         = bmAxpy(-a, F2p_curr, res_z2_curr);
        
        dagM_res_y_next     =             private_dagM(res_y_next, Gut, HX, HY, frSize, nFr, KFC_conj);
        dagF1_res_z1_next   = bmMult(rho, private_dagF1(res_z1_next, Tu1t, HX, HZ1, frSize, nFr, K_bump));
        dagF2_res_z2_next   = bmMult(rho, private_dagF2(res_z2_next, Tu2t, HX, HZ2, frSize, nFr, K_bump));
        
        dagA_res_next       = bmPlus(dagM_res_y_next, bmPlus(dagF1_res_z1_next, dagF2_res_z2_next)); 
        sqn_dagA_res_next   = bmSquaredNorm(dagA_res_next, HX);
        b                   = sqn_dagA_res_next/sqn_dagA_res_curr; 
        p_next              = bmAxpy(b, p_curr, dagA_res_next); 
        
    end
    % END_CGD -------------------------------------------------------------
    
    % updating_z_and_u ---------------------------------------------------- 
    F1x_plus_u1              = bmPlus(u1, private_F1(x, Tu1, frSize, nFr, K_bump)); 
    F2x_plus_u2              = bmPlus(u2, private_F2(x, Tu2, frSize, nFr, K_bump)); 
    z1                       = bmProx_oneNorm(F1x_plus_u1, delta/rho);
    z2                       = bmProx_oneNorm(F2x_plus_u2, delta/rho);
    u1                       = bmMinus(F1x_plus_u1, z1);
    u2                       = bmMinus(F2x_plus_u2, z2);
    % END_updating_z_and_u ------------------------------------------------
     
    
    % monitoring ----------------------------------------------------------
    [dafi, regul]                   = private_dafi_regul(x, y, Gu, Tu1, Tu2, HY, HZ1, HZ2, frSize, nFr, KFC, K_bump);
    
    objective                       = 0.5*dafi + 0.5*delta*regul; 
    witnessInfo.param{11}(1, c)     = objective; 
    witnessInfo.param{12}(1, c)     = dafi;  
    witnessInfo.param{13}(1, c)     = regul; 
    witnessInfo.watch(c, x, frSize, 'loop');
    % END_monitoring ------------------------------------------------------
    
end
disp(['... ', function_label, ' completed. '])
% END_ADMM loop -----------------------------------------------------------




% final -------------------------------------------------------------------
witnessInfo.watch(c, x, frSize, 'final');
x = bmBlockReshape(x, frSize);

if nargout > 1
    varargout{1} = z1; 
end
if nargout > 2
    varargout{2} = z2; 
end
if nargout > 3
    varargout{3} = u1; 
end
if nargout > 4
    varargout{4} = u2; 
end
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


function [dafi, regul]    = private_dafi_regul(x, y, Gu, Tu1, Tu2, HY, HZ1, HZ2, frSize, nFr, KFC, K_bump) 
    dafi   = 0;
    regul  = 0; 
    for i = 1:nFr
        temp_res    = y{i} - bmShanna(x{i}, Gu{i}, KFC, frSize, 'MATLAB'); % residu
        dafi        = dafi + bmSquaredNorm(temp_res, HY{i});   
        
        i_minus_1   = mod( (i-1) - 1, nFr) + 1; 
        temp_res    = x{i_minus_1} - bmImDeform(Tu1{i}, x{i}, frSize, K_bump);
        regul       = regul + HZ1*sum(abs(  real(temp_res(:))  )) + HZ1*sum(abs(  imag(temp_res(:))  ));      
        
        i_plus_1    = mod( (i+1) - 1, nFr) + 1; 
        temp_res    = x{i_plus_1} - bmImDeform(Tu2{i}, x{i}, frSize, K_bump);
        regul       = regul + HZ2*sum(abs(  real(temp_res(:))  )) + HZ2*sum(abs(  imag(temp_res(:))  ));
        
    end
end


function out_param = private_init_regul_param(in_param, nIter)

out_param       = single(  abs(in_param(:))  );
if size(out_param, 1) == 1
    out_param   = linspace(out_param, out_param, nIter);
elseif size(out_param, 1) == 2
    out_param   = linspace(out_param(1, 1), out_param(2, 1), nIter);
end
out_param = out_param(:)';
out_param = single(out_param); 

end


function [delta, rho] = private_adapt_delta_rho(dafi, regul, delta_factor, rho_factor)

% delta   = delta_factor*R/TV;  
delta   = delta_factor*regul/dafi;  
rho     = rho_factor*delta; 

end
% END_HELP_FUNCIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







% MODEL_AND_SPARSIFIER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% forward_model
function M_x = private_M(x, Gu, frSize, nFr, KFC)
    M_x = cell(nFr, 1); 
    for i = 1:nFr
        M_x{i}     = bmShanna(x{i}, Gu{i}, KFC, frSize, 'MATLAB');
    end
end


% forward_sparsifier_1
function F1_x = private_F1(x, Tu1, frSize, nFr, K_bump)
    F1_x = cell(nFr, 1); 
    for i = 1:nFr
        i_minus_1   = mod( (i-1) - 1, nFr) + 1;
        F1_x{i}     = 0.5*(bmImDeform(Tu1{i}, x{i}, frSize, K_bump) - x{i_minus_1}); 
    end
end

% forward_sparsifier_2
function F2_x = private_F2(x, Tu2, frSize, nFr, K_bump)
    F2_x = cell(nFr, 1); 
    for i = 1:nFr
        i_plus_1   = mod( (i+1) - 1, nFr) + 1;
        F2_x{i}    = 0.5*(bmImDeform(Tu2{i}, x{i}, frSize, K_bump) - x{i_plus_1}); 
    end
end

% adjoint_model
function dagM_y = private_dagM(y, Gut, HX, HY, frSize, nFr, KFC_conj)
    dagM_y = cell(nFr, 1); 
    for i = 1:nFr
        dagM_y{i} = (1/HX)*bmNakatsha(HY{i}.*y{i}, Gut{i}, KFC_conj, true, frSize, 'MATLAB'); % negative_gradient
    end
end


% adjoint_sparsifier_1
function dagF1_z = private_dagF1(z, Tu1t, HX, HZ1, frSize, nFr, K_bump)
    dagF1_z = cell(nFr, 1); 
    for i = 1:nFr
        i_plus_1   = mod( (i+1) - 1, nFr) + 1;
        dagF1_z{i} = (0.5/HX)*(   bmImDeformT(Tu1t{i}, HZ1*z{i}, frSize, K_bump) - HZ1*z{i_plus_1}  ); % negative_gradient
    end
end


% adjoint_sparsifier_2
function dagF2_z = private_dagF2(z, Tu2t, HX, HZ2, frSize, nFr, K_bump)
    dagF2_z = cell(nFr, 1); 
    for i = 1:nFr
        i_minus_1   = mod( (i-1) - 1, nFr) + 1;
        dagF2_z{i}  = (0.5/HX)*(   bmImDeformT(Tu2t{i}, HZ2*z{i}, frSize, K_bump) - HZ2*z{i_minus_1}  ); % negative_gradient
    end
end

% END_MODEL_AND_SPARSIFIER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

