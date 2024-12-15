% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmSensa(   x, y, ve, C, Gu, Gut, frSize, ...
                        nCGD, ve_max, ...
                        nIter, witnessInfo)

% initial -----------------------------------------------------------------
myEps       = 10*eps('single'); % --------------------------------------------- magic_number

y           = single(y);  
nCh         = size(y, 2); 
N_u         = double(single(Gu.N_u(:)')); 
frSize         = double(single(frSize(:)'));
dK_u        = double(single(Gu.d_u(:)'));
C           = single(bmColReshape(C, N_u));  
ve          = single(bmY_ve_reshape(ve, size(y)));  

KFC         = single(bmColReshape(bmKF(          C,  N_u, frSize, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam), frSize)); 
KFC_conj    = single(bmColReshape(bmKF_conj(conj(C), N_u, frSize, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam), frSize)); 

x = single(bmColReshape(x, frSize)); 

dX_u        = single(  (1./single(dK_u))./single(N_u)  );
HX          = prod(dX_u(:)); 

if isempty(ve_max)
   ve_max = max(ve(:));  
end
HY = min(ve, single(ve_max)); 

private_init_witnessInfo(witnessInfo, 'sensa', frSize, N_u, dK_u, nIter, nCGD, ve_max); 

% END_initial -------------------------------------------------------------

% main_loop ---------------------------------------------------------------
for c = 1:nIter
    
    res_next            = y - bmShanna(x, Gu, KFC, frSize, 'MATLAB');
    % compute the adjoint. 
    dagM_res_next       = (1/HX)*bmNakatsha(HY.*res_next, Gut, KFC_conj, true, frSize, 'MATLAB');
    % Initialization of the gradient descent
    sqn_dagM_res_next   = real(   dagM_res_next(:)'*(HX*dagM_res_next(:))   );
    p_next              = dagM_res_next;
    % Do many gradient descent. Note that you 
    for i = 1:nCGD
        
        res_curr    = res_next;
        sqn_dagM_res_curr = sqn_dagM_res_next; 
        p_curr      = p_next;
        
        if (sqn_dagM_res_curr < myEps) 
            break;
        end
        
        Mp_curr  = bmShanna(p_curr, Gu, KFC, frSize, 'MATLAB');
        sqn_Mp_curr      = real(   Mp_curr(:)'*(HY(:).*Mp_curr(:))   );
        
        a   = sqn_dagM_res_curr/sqn_Mp_curr;
        
        x = x + a*p_curr;
        
        
                
        if (i == nCGD)
           break;  
        end
        
        res_next            = res_curr - a*Mp_curr;
        dagM_res_next       = (1/HX)*bmNakatsha(HY.*res_next, Gut, KFC_conj, true, frSize, 'MATLAB');
        sqn_dagM_res_next   = real(   dagM_res_next(:)'*(HX*dagM_res_next(:))   );
        
        b = sqn_dagM_res_next/sqn_dagM_res_curr; 
        
        p_next              = dagM_res_next + b*p_curr;
        
    end % end CGD
    
    % monitoring ----------------------------------------------------------
    temp_r          = y - bmShanna(x, Gu, KFC, frSize, 'MATLAB');
    R               = real(  temp_r(:)'*(HY(:).*temp_r(:))  ); 
    witnessInfo.param{7}(1, c) = R;  
    witnessInfo.watch(c, x, frSize, 'loop'); 
    % END_monitoring ------------------------------------------------------

end
% END_main_loop -----------------------------------------------------------

% final -------------------------------------------------------------------
witnessInfo.watch(c, x, frSize, 'final'); 
x = bmBlockReshape(x, frSize); 
% END_final ---------------------------------------------------------------

end



function private_init_witnessInfo(witnessInfo, argName, frSize, N_u, dK_u, nIter, nCGD, ve_max)

witnessInfo.param_name{1}    = 'recon_name'; 
witnessInfo.param{1}         = argName; 

witnessInfo.param_name{2}    = 'dK_u'; 
witnessInfo.param{2}         = dK_u; 

witnessInfo.param_name{3}    = 'N_u'; 
witnessInfo.param{3}         = N_u; 

witnessInfo.param_name{4}    = 'frSize'; 
witnessInfo.param{4}         = frSize; 

witnessInfo.param_name{5}    = 'nIter'; 
witnessInfo.param{5}         = nIter; 

witnessInfo.param_name{6}    = 'nCGD'; 
witnessInfo.param{6}         = nCGD; 

witnessInfo.param_name{7}    = 've_max'; 
witnessInfo.param{7}         = ve_max;

witnessInfo.param_name{8}    = 'residu'; 
witnessInfo.param{8}         = zeros(1, nIter); 

end

