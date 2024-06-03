% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmSteva(  x, z, u, y, ve, C, Gu, Gut, n_u, ...
                                    delta, rho, nCGD, ve_max, ...
                                    convCond, witnessInfo)

% initial -----------------------------------------------------------------
myEps   = 10*eps('single'); % -------------------------------------------------- magic number
    
y               = single(y);   
nCh             = size(y, 2);
N_u             = double(int32(Gu.N_u(:)'));
n_u             = double(n_u(:)');
if isempty(n_u)
   n_u = N_u;  
end
nPt_u           = prod(n_u(:)); 
imDim           = size(N_u(:), 1);  
dK_u            = double(single(Gu.d_u(:)'));
dX_u            = single(  (1./single(dK_u))./single(N_u)  );

if isempty(ve_max)
   ve_max = max(ve(:));  
end

[delta, rho]    = private_init_delta_rho(delta, rho, convCond); 

HX              = single(  prod(dX_u(:))  );
HZ              = single(  prod(dX_u(:))  );
HY              = min(single(  bmY_ve_reshape(ve, size(y))  ), single(ve_max)); 
C               = single(bmColReshape(C, N_u));
KFC             = single(bmKF(          C,  N_u, n_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam));
KFC_conj        = single(bmKF_conj(conj(C), N_u, n_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam));

x = single(bmColReshape(x, n_u));

if isempty(z)
    z = bmBackGradient(x, n_u, dX_u);
end
if isempty(u)
    u = bmZero([nPt_u, imDim], 'complex_single');
end

private_init_witnessInfo(witnessInfo, convCond, 'steva', n_u, N_u, dK_u, delta, rho, nCGD, ve_max); 
% END_initial -------------------------------------------------------------



% ADMM loop ---------------------------------------------------------------
while convCond.check()
    
    c = convCond.nIter_curr; 

    res_y_next   = y - bmShanna(x, Gu, KFC, n_u, 'MATLAB');
    res_z_next   = (z - u) - bmBackGradient(x, n_u, dX_u);
    
    dagM_res_y_next  = (1/HX)*bmNakatsha(HY.*res_y_next, Gut, KFC_conj, true, n_u, 'MATLAB'); 
    dagF_res_z_next  = rho(1, c)*(1/HX)*bmBackGradientT(HZ*res_z_next, n_u, dX_u);
    
    dagA_res_next   = dagM_res_y_next + dagF_res_z_next; 
    p_next          = dagA_res_next; 
    
    sqn_dagA_res_next = real(   dagA_res_next(:)'*(HX*dagA_res_next(:))   );
    

    for i = 1:nCGD
        
        res_y_curr   = res_y_next;
        res_z_curr   = res_z_next;
        sqn_dagA_res_curr = sqn_dagA_res_next; 
        p_curr = p_next; 
        
        
        if (sqn_dagA_res_curr < myEps)
            break;
        end
        
        
        Mp_curr     = bmShanna(p_curr, Gu, KFC, n_u, 'MATLAB');
        Fp_curr     = bmBackGradient(p_curr, n_u, dX_u);
        
        sqn_Mp_curr      = real(   Mp_curr(:)'*(HY(:).*Mp_curr(:))   );
        sqn_Fp_curr      = real(   Fp_curr(:)'*(rho(1, c)*HZ*Fp_curr(:))   );
        sqn_Ap_curr       = sqn_Mp_curr + sqn_Fp_curr;
        
        a   = sqn_dagA_res_curr/sqn_Ap_curr;
        
        x = x + a*p_curr;
        
        if i == nCGD
            break;
        end
        
        res_y_next          = res_y_curr - a*Mp_curr;
        res_z_next          = res_z_curr - a*Fp_curr;
        
        dagM_res_y_next   = (1/HX)*bmNakatsha(HY.*res_y_next, Gut, KFC_conj, true, n_u, 'MATLAB');
        dagF_res_z_next   = rho(1, c)*(1/HX)*bmBackGradientT(HZ*res_z_next, n_u, dX_u);
        
        dagA_res_next     = dagM_res_y_next + dagF_res_z_next;
        sqn_dagA_res_next = real(   dagA_res_next(:)'*(HX*dagA_res_next(:))   );
        
        b = sqn_dagA_res_next/sqn_dagA_res_curr; 
        
        p_next           = dagA_res_next + b*p_curr;

    end

    bGx_plus_u      = bmBackGradient(x, n_u, dX_u) + u; 
    z               = bmProx_oneNorm(bGx_plus_u, delta(1, c)/rho(1, c)); 
    u               = bGx_plus_u - z; 
    
    
    % monitoring ----------------------------------------------------------
    temp_r          = y - bmShanna(x, Gu, KFC, n_u, 'MATLAB');
    R               = real(  temp_r(:)'*(HY(:).*temp_r(:))  ); 
    
    temp_r  = bmBackGradient(x, n_u, dX_u);
    TV      = HZ*sum(abs(  real(temp_r(:))  )) + HZ*sum(abs(  imag(temp_r(:))  ));
    
    witnessInfo.param{9}(1, c)  = R; 
    witnessInfo.param{10}(1, c) = TV; 
    % END_monitoring ------------------------------------------------------
    
    
    witnessInfo.watch(c, x, n_u, 'loop'); 
end
% END_ADMM loop -----------------------------------------------------------

% final -------------------------------------------------------------------
witnessInfo.watch(convCond.nIter_curr, x, n_u, 'final'); 
x = bmBlockReshape(x, n_u);
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

function private_init_witnessInfo(witnessInfo, convCond, argName, n_u, N_u, dK_u, delta, rho, nCGD, ve_max)

witnessInfo.param_name{1}    = 'recon_name'; 
witnessInfo.param{1}         = argName; 

witnessInfo.param_name{2}    = 'dK_u'; 
witnessInfo.param{2}         = dK_u; 

witnessInfo.param_name{3}    = 'N_u'; 
witnessInfo.param{3}         = N_u; 

witnessInfo.param_name{4}    = 'n_u'; 
witnessInfo.param{4}         = n_u; 

witnessInfo.param_name{5}    = 'delta'; 
witnessInfo.param{5}         = delta; 

witnessInfo.param_name{6}    = 'rho'; 
witnessInfo.param{6}         = rho; 

witnessInfo.param_name{7}    = 'nCGD'; 
witnessInfo.param{7}         = nCGD; 

witnessInfo.param_name{8}    = 've_max'; 
witnessInfo.param{8}         = ve_max;

witnessInfo.param_name{9}    = 'residu'; 
witnessInfo.param{9}         = zeros(1, convCond.nIter_max); 

witnessInfo.param_name{10}   = 'total_variation'; 
witnessInfo.param{10}        = zeros(1, convCond.nIter_max); 

end