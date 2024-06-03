% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmTevaMorphosia_chain_all_to_first(  x, z, u, y, ve, C, ...
                                            Gu, Gut, n_u, ...
                                            Tu, Tut, ...
                                            delta, rho, regul_mode, ...
                                            nCGD, ve_max, ...
                                            convCond, witnessInfo)

% initial -----------------------------------------------------------------

disp('tevaMorphosia_all_to_first initial...'); 

myEps           = 10*eps('single'); % ---------------------------------------------------- magic number

y               = bmSingle_of_cell(y);
nCh             = size(y{1}, 2);
nFr             = size(y(:), 1);
N_u             = double(int32(Gu{1}.N_u(:)'));
if isempty(n_u)
    n_u = N_u;
end
n_u             = double(int32(n_u(:)'));
nPt_u           = prod(n_u(:));
dK_u            = double(single(Gu{1}.d_u(:)'));

dX_u            = single(  (1./single(dK_u))./single(N_u)  );
HX              = single(  prod(dX_u(:))  );
HZ              = HX; 

[delta_list, rho_list]    = private_init_delta_rho(delta, rho, convCond); 

if isempty(ve_max)
   ve_max = single(bmMax(ve)); 
end

HY = cell(nFr, 1); 
for i = 1:nFr
    ve{i}       = single(bmY_ve_reshape(ve{i}, size(y{i})  ));
    HY{i}       = min(ve{i}, single(ve_max)); 
end
C               = single(bmBlockReshape(C, n_u));
KFC             = single(bmKF(          C,  N_u, n_u, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));
KFC_conj        = single(bmKF_conj(conj(C), N_u, n_u, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));
% K_bump        = bmK_bump(N_u).^(0.5); 
K_bump          = []; 

for i = 1:nFr    
    x{i} = single(bmColReshape(x{i}, n_u));
end

if isempty(Tu)
    Tu = cell(nFr, 1); 
end
if isempty(Tut)
    Tut = cell(nFr, 1); 
end

private_init_witnessInfo(witnessInfo, convCond, 'bmTevaMorphosia_all_to_first', n_u, N_u, dK_u, delta, rho, nCGD, ve_max); 

res_y_next      = cell(nFr, 1);
res_z_next      = cell(nFr, 1);
dagA_res_next   = cell(nFr, 1);
Mp_curr         = cell(nFr, 1);
Fp_curr         = cell(nFr, 1);

myZero = bmZero([nPt_u, 1], 'complex_single'); 

% initial of z and u
if isempty(z)
    z = cell(nFr, 1);
    z{1} = myZero;     
    for i = 2:nFr
        z{i}        = bmImDeform(Tu{i}, x{i}, n_u, K_bump) - x{1}; % z{i} = Bx{i}
    end
end
if isempty(u)
    u = cell(nFr, 1);
    for i = 1:nFr
        u{i}        = bmZero([nPt_u, 1], 'complex_single');
    end
end

disp('... initial done. ');
% END_initial -------------------------------------------------------------


% ADMM loop ---------------------------------------------------------------
while convCond.check()
    
    c = convCond.nIter_curr; 
    
    if strcmp(regul_mode, 'normal')
        delta   = delta_list(1, c);
        rho     = rho_list(1, c);
    elseif strcmp(regul_mode, 'adapt')
        [delta, rho] = private_adapt_delta_rho(R, TV, delta_list(1, c), rho_list(1, c)); 
    end
    
    rho_Hz  = rho*HZ;  
    
    % CGD -----------------------------------------------------------------
    
    % initial_CGD
    for i = 1:nFr
        res_y_next{i} = y{i} - bmShanna(x{i}, Gu{i}, KFC, n_u, 'MATLAB');
        
        if i == 1
            res_z_next{i} = z{i} - u{i};
        else
            res_z_next{i} = z{i} - u{i} - ( bmImDeform(Tu{i}, x{i}, n_u, K_bump) - x{1} );
        end
    end
    
    for i = 1:nFr
        dagM_res_y_next = (1/HX)*bmNakatsha(HY{i}.*res_y_next{i}, Gut{i}, KFC_conj, true, n_u, 'MATLAB'); % negative_gradient
        
        if i == 1
            dagF_res_z_next = 0;
            for j = 2:nFr
                dagF_res_z_next = dagF_res_z_next - (1/HX)*rho_HZ*res_z_next{j};
            end
        else
            dagF_res_z_next = (1/HX)*bmImDeformT(Tut{i}, rho_HZ*res_z_next{i}, n_u, K_bump); % negative_gradient
        end
        dagA_res_next{i} = dagM_res_y_next + dagF_res_z_next;
    end
    
    p_next = dagA_res_next;
    
    sqn_dagA_res_next = 0; 
    for i = 1:nFr
        sqn_dagA_res_next = sqn_dagA_res_next + HX*real(dagA_res_next{i}(:)'*dagA_res_next{i}(:));
    end
    
    % END_initial_CGD
    
    % loop_CGD
    for j = 1:nCGD
        
        res_y_curr = res_y_next;
        res_z_curr = res_z_next;
        sqn_dagA_res_curr = sqn_dagA_res_next; 
        p_curr = p_next;
        
        if(sqn_dagA_res_curr < myEps)
            break;
        end
        
        
        for i = 1:nFr
            Mp_curr{i}     = bmShanna(p_curr{i}, Gu{i}, KFC, n_u, 'MATLAB');
            if i == 1
                Fp_curr{i}  = myZero; 
            else
                Fp_curr{i}  = bmImDeform(Tu{i}, p_curr{i}, n_u, K_bump) - p_curr{1};
            end
        end
        
        sqn_Mp_curr = 0;
        sqn_Fp_curr = 0;
        for i = 1:nFr
            sqn_Mp_curr = sqn_Mp_curr + real(  Mp_curr{i}(:)'*bmCol(HY{i}.*Mp_curr{i})  ); 
            sqn_Fp_curr = sqn_Fp_curr + rho_Hz*real(  Fp_curr{i}(:)'*Fp_curr{i}(:)  );
        end
        sqn_Ap_curr = sqn_Mp_curr + sqn_Fp_curr; 
        
        a = sqn_dagA_res_curr/sqn_Ap_curr;
        
        for i = 1:nFr
            x{i} = x{i} + a*p_curr{i};
        end
        
        if j == nCGD
            break;
        end
        
        for i = 1:nFr
            res_y_next{i} = res_y_curr{i} - a*Mp_curr{i};
            res_z_next{i} = res_z_curr{i} - a*Fp_curr{i};
        end
        
        for i = 1:nFr
            dagM_res_y_next = (1/HX)*bmNakatsha(HY{i}.*res_y_next{i}, Gut{i}, KFC_conj, true, n_u, 'MATLAB'); % negative_gradient
            
            if i == 1
                dagF_res_z_next = 0;
                for j = 2:nFr
                    dagF_res_z_next = dagF_res_z_next - (1/HX)*rho_HZ*res_z_next{j};
                end
            else
                dagF_res_z_next = (1/HX)*bmImDeformT(Tut{i}, rho_HZ*res_z_next{i}, n_u, K_bump); % negative_gradient
            end
            dagA_res_next{i} = dagM_res_y_next + dagF_res_z_next;
        end
        
        sqn_dagA_res_next = 0;
        for i = 1:nFr
            sqn_dagA_res_next = sqn_dagA_res_next + HX*real(dagA_res_next{i}(:)'*dagA_res_next{i}(:));
        end
        
        b = sqn_dagA_res_next/sqn_dagA_res_curr; 
        
        for i = 1:nFr
            p_next{i} =  sqn_dagA_res_next{i} + b*p_curr{i};
        end
        
    end
    % END_loop_CGD
    
    % END_CGD -------------------------------------------------------------
    
    
    
    % updating_z_and_u ---------------------------------------------------- 
    for i = 1:nFr
        if i == 1
            Fx_plus_u{i}    = u{i};
        else
            Fx_plus_u{i}    = bmImDeform(Tu{i}, x{i}, n_u, K_bump) - x{1} + u{i};
        end
    end
    
    
    for i = 1:nFr
        z{i}            = bmProx_oneNorm(Fx_plus_u{i}, delta/rho);
        u{i}            = Fx_plus_u{i} - z{i};
    end
    % END_updating_z_and_u ------------------------------------------------
    
    
    % monitoring ----------------------------------------------------------
    R   = 0;
    for i = 1:nFr
        temp_res  = y{i} - bmShanna(x{i}, Gu{i}, KFC, n_u, 'MATLAB'); % residu
        R       = R + real(  temp_res(:)'*(  ve{i}(:).*temp_res(:)  )  );
    end
    
    TV  = 0;
    for i = 2:nFr
        temp_res  = bmImDeform(Tu{i}, x{i}, n_u, K_bump) - x{1};
        TV      = TV + HZ*sum(abs(  real(temp_res(:))  )) + HZ*sum(abs(  imag(temp_res(:))  ));
    end
    
    
    witnessInfo.param{wit_residu_ind}(1, c)     = R;  
    witnessInfo.param{wit_TV_ind}(1, c)         = TV;  
    witnessInfo.watch(c, x, n_u, 'loop');
    % END_monitoring ------------------------------------------------------
    
end
% END_ADMM loop -----------------------------------------------------------


% final -------------------------------------------------------------------
witnessInfo.watch(convCond.nIter_curr, x, n_u, 'final');
for i = 1:nFr
    x{i} = bmBlockReshape(x{i}, n_u);
end
% END_final ---------------------------------------------------------------

end


function [delta, rho] = private_init_delta_rho(delta, rho, convCond)

rho             = single(  abs(rho(:))  );
delta           = single(  abs(delta(:))  );
if size(delta, 1) == 1
    delta   = linspace(delta, delta, convCond.nIter_max);
elseif size(delta, 1) == 2
    delta   = linspace(delta(1, 1), delta(2, 1), convCond.nIter_max);
end
delta = delta(:)';
if size(rho, 1) == 1
    rho     = linspace(rho,     rho, convCond.nIter_max);
elseif size(rho, 1) == 2
    rho     = linspace(rho(1, 1),     rho(2, 1), convCond.nIter_max);
end
rho = rho(:)';

end


function [delta, rho] = private_adapt_delta_rho(R, TV, delta_factor, rho_factor)

% delta   = delta_factor*R/TV;  
delta   = delta_factor*TV/R;  
rho     = rho_factor*delta; 

end


function private_init_witnessInfo(witnessInfo, convCond, arg_name, n_u, N_u, dK_u, delta, rho, nCGD, ve_max)

witnessInfo.param_name{1}       = 'recon_name';
witnessInfo.param{1}            =  arg_name; 

witnessInfo.param_name{2}       = 'dK_u'; 
witnessInfo.param{2}            = dK_u; 

witnessInfo.param_name{3}       = 'N_u'; 
witnessInfo.param{3}            = N_u; 

witnessInfo.param_name{4}       = 'n_u'; 
witnessInfo.param{4}            = n_u; 

witnessInfo.param_name{5}       = 'delta'; 
witnessInfo.param{5}            = delta; 

witnessInfo.param_name{6}       = 'rho'; 
witnessInfo.param{6}            = rho; 

witnessInfo.param_name{7}       = 'nCGD'; 
witnessInfo.param{7}            = nCGD; 

witnessInfo.param_name{8}       = 've_max'; 
witnessInfo.param{8}            = ve_max;

witnessInfo.param_name{9}       = 'regul_mode'; 
witnessInfo.param{9}            = regul_mode;

wit_residu_ind = 10; 
witnessInfo.param_name{10}      = 'data_fidelity'; 
witnessInfo.param{10}           = zeros(1, convCond.nIter_max); 

wit_TV_ind = 11; 
witnessInfo.param_name{11}      = 'tTV'; 
witnessInfo.param{11}           = zeros(1, convCond.nIter_max); 

end




