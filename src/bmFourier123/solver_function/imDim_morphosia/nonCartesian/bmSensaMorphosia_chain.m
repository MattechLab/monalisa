% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmSensaMorphosia_chain(  x, y, ve, C, Gu, Gut, n_u, ...
                                Tu, Tut, ...
                                nCGD, ve_max, ...
                                convCond, witnessInfo)

% initial -----------------------------------------------------------------
myEps       = 10*eps('single'); % ---------------------------------------------------- magic number

y               = bmSingle_of_cell(y);
nCh             = size(y{1}, 2);
N_u             = double(int32(Gu{1}.N_u(:)'));
if isempty(n_u)
    n_u = N_u;
end
dK_u            = double(single(Gu{1}.d_u(:)'));
nFr             = size(y(:), 1);

dX_u            = 1./dK_u./N_u; 
HX              = single(prod(dX_u(:))); 

if isempty(ve_max)
   ve_max = bmMax(ve); 
end
for i = 1:nFr
    ve{i}       = single(bmY_ve_reshape(ve{i}, size(y{i})));
    ve{i}       = min(ve{i}, single(ve_max)); 
    HY{i}       = ve{i}; 
end

C               = single(bmColReshape(C, N_u));
KFC             = single(bmKF(          C,  N_u, n_u, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));
KFC_conj        = single(bmKF_conj(conj(C), N_u, n_u, dK_u, nCh, Gu{1}.kernel_type, Gu{1}.nWin, Gu{1}.kernelParam));

% K_bump        = bmK_bump(n_u).^(1/2);
K_bump          = [];

if iscell(x)
    x = single(bmColReshape(x{1}, n_u));
else
    x = single(bmColReshape(x, n_u));
end

if isempty(Tu)
    Tu = cell(nFr, 1);
end
if isempty(Tut)
    Tut = cell(nFr, 1);
end

private_init_witnessInfo(witnessInfo, convCond, 'sensaMorphosia', n_u, N_u, dK_u, nCGD, ve_max); 

res_next    = cell(nFr, 1); 
Ap_curr     = cell(nFr, 1); 

% END_initial -------------------------------------------------------------

while convCond.check()
    
    c = convCond.nIter_curr;
    
    % initial of CGD ----------------------------------------------------------
    for i = 1:nFr
        intermed = bmImDeform(Tu{i}, x, n_u, K_bump);
        res_next{i} = y{i} - bmShanna(intermed, Gu{i}, KFC, n_u, 'MATLAB');
    end
    
    
    for i = 1:nFr
        intermed   = bmNakatsha(HY{i}.*res_next{i}, Gut{i}, KFC_conj, true, n_u, 'MATLAB');
        if i == 1
            dagA_res_next    = (1/HX)*bmImDeformT(Tut{i}, intermed, n_u, K_bump);
        elseif i > 1
            dagA_res_next    = dagA_res_next + (1/HX)*bmImDeformT(Tut{i}, intermed, n_u, K_bump);
        end
    end
    
    sqn_dagA_res_next = real(  dagA_res_next(:)'*(HX*dagA_res_next(:))  );
    p_next = dagA_res_next;
    % END_initial of CGD ------------------------------------------------------
    
    
    % loop of CGD -------------------------------------------------------------
    
    for j = 1:nCGD
        
        res_curr = res_next;
        p_curr = p_next;
        sqn_dagA_res_curr = sqn_dagA_res_next;
        
        if(sqn_dagA_res_curr < myEps)
            break;
        end
        
        % Ap_curr = A*p_curr; 
        for i = 1:nFr
            intermed    = bmImDeform(Tu{i}, p_curr, n_u, K_bump);
            Ap_curr{i}  = bmShanna(intermed, Gu{i}, KFC, n_u, 'MATLAB');
        end
        
        % sqn_Ap_curr
        sqn_Ap_curr = 0;
        for i = 1:nFr
            sqn_Ap_curr = sqn_Ap_curr + real(  Ap_curr{i}(:)'*bmCol(HY{i}.*Ap_curr{i})  );
        end
        
        a = sqn_dagA_res_curr/sqn_Ap_curr;
        
        x = x + a*p_curr;
        
        if j == nCGD
           break;  
        end
        
        for i = 1:nFr
            res_next{i} = res_curr{i} - a*Ap_curr{i};
        end
        
        for i = 1:nFr
            intermed             = bmNakatsha(HY{i}.*res_next{i}, Gut{i}, KFC_conj, true, n_u, 'MATLAB');
            if i == 1
                dagA_res_next    = (1/HX)*bmImDeformT(Tut{i}, intermed, n_u, K_bump);
            elseif i > 1
                dagA_res_next    = dagA_res_next + (1/HX)*bmImDeformT(Tut{i}, intermed, n_u, K_bump);
            end
        end
        
        sqn_dagA_res_next = real(  dagA_res_next(:)'*(HX*dagA_res_next(:))  );
        
        b       = sqn_dagA_res_next/sqn_dagA_res_curr; 
        p_next = dagA_res_next + b*p_curr;
        
        
    end
    % END_loop of CGD -----------------------------------------------------
    
    
    % monitoring ----------------------------------------------------------
    for i = 1:nFr
        intermed    = bmImDeform(Tu{i}, x, n_u, K_bump);
        temp_res{i} = y{i} - bmShanna(intermed, Gu{i}, KFC, n_u, 'MATLAB');
    end
    R = 0; 
    for i = 1:nFr
       R = R + real(  temp_res{i}(:)'*(  HY{i}(:).*temp_res{i}(:)  )  );  
    end
    
    witnessInfo.param{7}(1, c) = R;  
    witnessInfo.watch(c, x, n_u, 'loop');
    % END_monitoring ------------------------------------------------------
    
    
end % END_main_loop

% final -------------------------------------------------------------------
witnessInfo.watch(convCond.nIter_curr, x, n_u, 'final');
x = bmBlockReshape(x, n_u);
% END_final ---------------------------------------------------------------

end


function private_init_witnessInfo(witnessInfo, convCond, argName, n_u, N_u, dK_u, nCGD, ve_max)

witnessInfo.param_name{1}    = 'recon_name'; 
witnessInfo.param{1}         = argName; 

witnessInfo.param_name{2}    = 'dK_u'; 
witnessInfo.param{2}         = dK_u; 

witnessInfo.param_name{3}    = 'N_u'; 
witnessInfo.param{3}         = N_u; 

witnessInfo.param_name{4}    = 'n_u'; 
witnessInfo.param{4}         = n_u; 

witnessInfo.param_name{5}    = 'nCGD'; 
witnessInfo.param{5}         = nCGD; 

witnessInfo.param_name{6}    = 've_max'; 
witnessInfo.param{6}         = ve_max;

witnessInfo.param_name{7}    = 'residu'; 
witnessInfo.param{7}         = zeros(1, convCond.nIter_max); 

end


