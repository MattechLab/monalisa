% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmSensa_partialCartesian(  x, y, ve, C, ind_u, N_u, n_u, dK_u, ...
                                        nCGD, ve_max, ...
                                        convCond, witnessInfo)

% initial -----------------------------------------------------------------
myEps       = 10*eps('single'); % --------------------------------------------- magic_number

y           = single(y);  
nCh         = size(y, 2); 
N_u         = double(single(N_u(:)')); 
n_u         = double(single(n_u(:)')); 
dK_u        = double(single(dK_u(:)'));
ve          = single(bmY_ve_reshape(ve, size(y)));  

C               = single(bmBlockReshape(C, n_u));
FC              = single(bmFC(          C,  N_u, n_u, dK_u)  );
FC_conj         = single(bmFC_conj(conj(C), N_u, n_u, dK_u)  ); 

x = single(bmColReshape(x, N_u)); 

if isempty(ve_max)
   ve_max = max(ve(:));  
end
HY = min(ve, single(ve_max)); 

dX_u        = single(  (1./single(dK_u))./single(N_u)  );
HX          = prod(dX_u(:)); 

private_init_witnessInfo(witnessInfo, convCond, 'sensa_partialCartesian', n_u, N_u, dK_u, nCGD, ve_max); 

% END_initial -------------------------------------------------------------


% main_loop ---------------------------------------------------------------
while convCond.check()
    
    c = convCond.nIter_curr; 
    
    res_next          = y - bmShanna_partialCartesian(x, ind_u, FC, N_u, n_u, dK_u); 
    dagM_res_next     = (1/HX)*bmNakatsha_partialCartesian(HY.*res_next, ind_u, FC_conj, N_u, n_u, dK_u); 
    sqn_dagM_res_next = real(   dagM_res_next(:)'*(HX*dagM_res_next(:))   );
    p_next   = dagM_res_next;
    
    for j = 1:nCGD
        
        res_curr    = res_next;
        sqn_dagM_res_curr = sqn_dagM_res_next; 
        p_curr      = p_next;
        
        if (sqn_dagM_res_curr < myEps) 
            break;
        end
              
        Mp_curr  = bmShanna_partialCartesian(p_curr, ind_u, FC, N_u, n_u, dK_u);
        sqn_Mp_curr   = real(   Mp_curr(:)'*(HY(:).*Mp_curr(:))   );
        
        a   = sqn_dagM_res_curr/sqn_Mp_curr;
        
        x = x + a*p_curr;
        
        
                
        if (i == nCGD)
           break;  
        end
        
        res_next            = res_curr - a*Mp_curr;
        dagM_res_next       = (1/HX)*bmNakatsha_partialCartesian(HY.*res_next, ind_u, FC_conj, N_u, n_u, dK_u); 
        sqn_dagM_res_next   = real(   dagM_res_next(:)'*(HX*dagM_res_next(:))   );
        
        b = sqn_dagM_res_next/sqn_dagM_res_curr;
        
        p_next              = dagM_res_next + b*p_curr;
        
    end % end CGD
    
    % monitoring ----------------------------------------------------------
    temp_r  = y - bmShanna_partialCartesian(x, ind_u, FC, N_u, n_u, dK_u); 
    R       = real(  temp_r(:)'*(HY(:).*temp_r(:))  ); 
    witnessInfo.param{7}(1, c) = R;  
    witnessInfo.watch(c, x, n_u, 'loop'); 
    % END_monitoring ------------------------------------------------------

end
% END_main_loop -----------------------------------------------------------

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

