% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmTevaMorphosia_partialCartesian(  x, z, u, y, ve, C, N_u, frSize, dK_u, ...
                                                ind_u, ... 
                                                Tu, Tut, ...
                                                delta, rho, regul_mode, ...
                                                nCGD, ve_max, ...
                                                nIter, witnessInfo)

% initial -----------------------------------------------------------------

disp('tevaMorphosia_partialCartesian initial...'); 

myEps           = 10*eps('single'); % ---------------------------------------------------- magic_number

y               = bmSingle_of_cell(y);
nCh             = size(y{1}, 2);
N_u             = double(int32(N_u(:)'));
if isempty(frSize)
    frSize = N_u;
end
frSize             = double(int32(frSize(:)'));
nPt_u           = prod(frSize(:));
dK_u            = double(single(dK_u(:)'));

dX_u            = single(  (1./single(dK_u))./single(N_u)  );
Du              = single(  prod(dX_u(:))  );


delta           = single(  abs(delta(:))  ); 
rho             = single(  abs(rho(:))  );
delta_list      = []; 
rho_list        = [];
if size(delta, 1) == 1
    delta_list  = linspace(delta, delta, nIter);
elseif size(delta, 1) == 2  
    delta_list  = linspace(delta(1, 1), delta(2, 1), nIter); 
end
delta_list = delta_list(:)'; 
if size(rho, 1) == 1
    rho_list    = linspace(rho,     rho, nIter);
elseif size(rho, 1) == 2   
    rho_list    = linspace(rho(1, 1),     rho(2, 1), nIter); 
end
rho_list = rho_list(:)'; 

nFr             = size(y(:), 1);


if isempty(ve_max)
   ve_max = single(bmMax(ve)); 
end
for i = 1:nFr
    
    ve{i}       = single(bmY_ve_reshape(ve{i}, size(y{i})  ));
    ve{i}       = min(ve{i}, single(ve_max)); 
    
end
C               = single(bmBlockReshape(C, frSize));
FC              = single(bmFC(          C,  N_u, frSize, dK_u)  );
FC_conj         = single(bmFC_conj(conj(C), N_u, frSize, dK_u)  ); 


for i = 1:nFr    
    
    x{i} = single(bmColReshape(x{i}, frSize));

end

if isempty(Tu)
    Tu = cell(nFr, 1); 
end
if isempty(Tut)
    Tut = cell(nFr, 1); 
end




witnessInfo.param_name{1}    = 'recon_name';
witnessInfo.param{1}         = 'tevaMorphosia_partialCartesian'; 

witnessInfo.param_name{2}    = 'dK_u'; 
witnessInfo.param{2}         = dK_u; 

witnessInfo.param_name{3}    = 'N_u'; 
witnessInfo.param{3}         = N_u; 

witnessInfo.param_name{4}    = 'frSize'; 
witnessInfo.param{4}         = frSize; 

witnessInfo.param_name{5}    = 'delta'; 
witnessInfo.param{5}         = delta; 

witnessInfo.param_name{6}    = 'rho'; 
witnessInfo.param{6}         = rho; 

witnessInfo.param_name{7}    = 'nIter'; 
witnessInfo.param{7}         = nIter; 

witnessInfo.param_name{8}    = 'nCGD'; 
witnessInfo.param{8}         = nCGD; 

witnessInfo.param_name{9}    = 've_max'; 
witnessInfo.param{9}         = ve_max;

witnessInfo.param_name{10}    = 'regul_mode'; 
witnessInfo.param{10}         = regul_mode;

wit_residu_ind = 11; 
witnessInfo.param_name{11}    = 'residu'; 
witnessInfo.param{11}         = zeros(1, nIter); 

wit_TV_ind = 12; 
witnessInfo.param_name{12}   = 'total_variation'; 
witnessInfo.param{12}        = zeros(1, nIter); 

Vx_plus_u       = cell(nFr, 1);
q1_next         = cell(nFr, 1);
q2_next         = cell(nFr, 1);
temp_B_q_next   = cell(nFr, 1);
A1_p            = cell(nFr, 1);
A2_p            = cell(nFr, 1);


% initial of z and u
if isempty(z)
    z = cell(nFr, 1);
    for i = 1:nFr
        i_minus_1   = mod(i - 2, nFr) + 1;
        z{i}        = bmImDeform(Tu{i}, x{i}, frSize, []) - x{i_minus_1}; % z{i} = Bx{i}
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
for c = 1:nIter
    
    if strcmp(regul_mode, 'normal')
        delta   = delta_list(1, c);
        rho     = rho_list(1, c);
    elseif strcmp(regul_mode, 'adapt')
        [delta, rho] = private_adapt_delta_rho(R, TV, delta_list(1, c), rho_list(1, c)); 
    end
    Du_rho  = Du*rho;  
    
    % initial of CGD
    for i = 1:nFr
        i_minus_1 = mod(i - 2, nFr) + 1;
        q1_next{i} = y{i} - bmShanna_partialCartesian(x{i}, ind_u{i}, FC, N_u, frSize, dK_u);
        q2_next{i} = z{i} - u{i} + x{i_minus_1} - bmImDeform(Tu{i}, x{i}, frSize, []);
    end
    
    for i = 1:nFr
        i_plus_1 = mod(i, nFr) + 1;
        temp_B1_q1_next = bmNakatsha_partialCartesian(ve{i}.*q1_next{i}, ind_u{i}, FC_conj, N_u, frSize, dK_u); % negative_gradient
        temp_B2_q2_next = Du_rho*(  bmImDeformT(Tut{i}, q2_next{i}, frSize, []) - q2_next{i_plus_1} ); % negative_gradient
        temp_B_q_next{i} = temp_B1_q1_next + temp_B2_q2_next;
    end
    
    Q_next = 0; 
    for i = 1:nFr
        Q_next = Q_next + real(temp_B_q_next{i}(:)'*temp_B_q_next{i}(:));
    end
    
    p_next = temp_B_q_next;
    
    % END initial of CGD
    
    for j = 1:nCGD
        
        q1 = q1_next;
        q2 = q2_next;
        p = p_next;
        Q = Q_next;
        if(Q < myEps)
            break;
        end
        
        for i = 1:nFr
            i_minus_1   = mod(i - 2, nFr) + 1;
            A1_p{i}     = bmShanna_partialCartesian(p{i}, ind_u{i}, FC, N_u, frSize, dK_u);
            A2_p{i}     = bmImDeform(Tu{i}, p{i}, frSize, []) - p{i_minus_1};
        end
        
        P = 0;
        for i = 1:nFr
            P = P + real(  A1_p{i}(:)'*bmCol(ve{i}.*A1_p{i})  ) + Du_rho*real(  A2_p{i}(:)'*A2_p{i}(:)  );
        end
        
        a = Q/P;
        
        for i = 1:nFr
            x{i} = x{i} + a*p{i};
        end
        
        if j == nCGD
            break;
        end
        
        for i = 1:nFr
            q1_next{i} = q1{i} - a*A1_p{i};
            q2_next{i} = q2{i} - a*A2_p{i};
        end
        
        
        for i = 1:nFr
            i_plus_1 = mod(i, nFr) + 1;
            temp_B1_q1_next = bmNakatsha_partialCartesian(ve{i}.*q1_next{i}, ind_u{i}, FC_conj, N_u, frSize, dK_u);
            temp_B2_q2_next = Du_rho*(  bmImDeformT(Tut{i}, q2_next{i}, frSize, []) - q2_next{i_plus_1} );
            temp_B_q_next{i} = temp_B1_q1_next + temp_B2_q2_next;
        end
        
        Q_next = 0;
        for i = 1:nFr
            Q_next = Q_next + real(  temp_B_q_next{i}(:)'*temp_B_q_next{i}(:)  );
        end
        
        for i = 1:nFr
            p_next{i} =  temp_B_q_next{i} + (Q_next/Q)*p{i};
        end
        
    end % END CGD
    
    % update of z and u 
    for i = 1:nFr
        i_minus_1       = mod(i - 2, nFr) + 1;
        Vx_plus_u{i}    = bmImDeform(Tu{i}, x{i}, frSize, []) - x{i_minus_1} + u{i};
    end
    for i = 1:nFr
        z{i}            = bmProx_oneNorm(Vx_plus_u{i}, delta/rho);
        u{i}            = Vx_plus_u{i} - z{i};
    end
    
    % evaluation of the two different terms of the objective function
    R   = 0;
    TV  = 0; 
    for i = 1:nFr
        i_minus_1 = mod(i - 2, nFr) + 1;
        
        temp_r  = y{i} - bmShanna_partialCartesian(x{i}, ind_u{i}, FC, N_u, frSize, dK_u); % residu
        R       = R + real(  temp_r(:)'*(  ve{i}(:).*temp_r(:)  )  );  
        
        temp_r  = x{i_minus_1} - bmImDeform(Tu{i}, x{i}, frSize, []);
        TV      = TV + Du*sum(abs(  temp_r(:)  ));
        
    end 
    
    
    witnessInfo.param{wit_residu_ind}(1, c)     = R;  
    witnessInfo.param{wit_TV_ind}(1, c)         = TV;  
    witnessInfo.watch(c, x, frSize, 'loop');
end
% END_ADMM loop -----------------------------------------------------------


% final -------------------------------------------------------------------
witnessInfo.watch(c, x, frSize, 'final');
for i = 1:nFr
    x{i} = bmBlockReshape(x{i}, frSize);
end
% END_final ---------------------------------------------------------------

end



function [delta, rho] = private_adapt_delta_rho(R, TV, delta_factor, rho_factor)

% delta   = delta_factor*R/TV;  
delta   = delta_factor*TV/R;  
rho     = rho_factor*delta; 

end