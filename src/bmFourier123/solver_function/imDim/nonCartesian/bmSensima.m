% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmSensima(x, y, ve, C, Gu, Gut, convCond)


% recursive ---------------------------------------------------------------
if iscell(y)
    myCell_length = size(y(:), 1);  
    for i = 1:myCell_length
        disp(['Sensima on cell number ', num2str(i), ' of ', num2str(myCell_length)]);
        x{i} = bmSensima(x{i}, y{i}, ve{i}, C, Gu{i}, Gut{i}, bmConvergeCondition(convCond));
    end
    return;    
end
% END_recursive -----------------------------------------------------------



% initial -----------------------------------------------------------------
nIter_sense = 3; % ------------------------------------------------------------ magic_number
y           = single(y);  
nCh         = size(y, 2); 
N_u         = double(single(Gu.N_u(:)')); 
dK_u        = double(single(Gu.d_u(:)'));
C           = single(bmColReshape(C, N_u));  
ve          = single(bmY_ve_reshape(ve, size(y)));  

KFC         = single(bmColReshape(bmKF(          C,  N_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam), N_u)); 
KFC_conj    = single(bmColReshape(bmKF_conj(conj(C), N_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam), N_u)); 

x = single(bmColReshape(x, N_u)); 

% END_initial -------------------------------------------------------------

% main_loop ---------------------------------------------------------------
while convCond.check()    
    x = bmColReshape(bmImCrossMean(bmBlockReshape(x, N_u)), N_u); 
    x = private_sensa(x, y, ve, Gu, Gut, KFC, KFC_conj, bmConvergeCondition(nIter_sense)); 
    convCond.disp_info('Sensima'); 
end
% END_main_loop -----------------------------------------------------------


% final -------------------------------------------------------------------
x = bmBlockReshape(x, N_u); 
% END_final ---------------------------------------------------------------

end


function x = private_sensa(x, y, ve, Gu, Gut, KFC, KFC_conj, convCond)

myEps       = 10*eps('single'); % --------------------------------------------- magic_number

q_next   = y - bmShanna(x, Gu, KFC);  
Bq_next  = bmNakatsha(ve.*q_next, Gut, KFC_conj, true); 
Q_next   = real(   Bq_next(:)'*Bq_next(:)   );
p_next   = Bq_next;

while convCond.check()

    q   = q_next;
    p   = p_next;
    Q   = Q_next; 
    
    if Q < myEps
        break;
    end
        
    Ap  = bmShanna(p, Gu, KFC); 
    P   = real(   Ap(:)'*(ve(:).*Ap(:))   );
    a   = Q/P;
    
    x = x + a*p;
    
    if convCond.nIter_curr == convCond.nIter_max
        break; 
    end
    
    q_next          = q - a*Ap;
    temp_Bq_next    = bmNakatsha(ve.*q_next, Gut, KFC_conj, true);
    Q_next          = real(   temp_Bq_next(:)'*temp_Bq_next(:)   );
    p_next          = temp_Bq_next + (Q_next/Q)*p;
    
end

end