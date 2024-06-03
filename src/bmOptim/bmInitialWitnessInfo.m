% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmInitialWitnessInfo(witnessInfo, varargin)

[   function_label, ...
    N_u, n_u, dK_u, ve_max...
    nIter_max, ...
    nCGD, ...
    delta, rho, ...
    regul_mode] = bmVarargin(varargin); 

witnessInfo.param_name{1}       = 'function_label';
witnessInfo.param{1}            =  function_label; 

witnessInfo.param_name{2}       = 'N_u'; 
witnessInfo.param{2}            =  N_u; 

witnessInfo.param_name{3}       = 'n_u'; 
witnessInfo.param{3}            =  n_u; 

witnessInfo.param_name{4}       = 'dK_u'; 
witnessInfo.param{4}            =  dK_u; 

witnessInfo.param_name{5}       = 've_max'; 
witnessInfo.param{5}            =  ve_max;

witnessInfo.param_name{6}       = 'nIter_max'; 
witnessInfo.param{6}            =  nIter_max; 

witnessInfo.param_name{7}       = 'nCGD'; 
witnessInfo.param{7}            =  nCGD; 

witnessInfo.param_name{8}       = 'delta'; 
witnessInfo.param{8}            =  delta; 

witnessInfo.param_name{9}       = 'rho'; 
witnessInfo.param{9}            =  rho; 

witnessInfo.param_name{10}       = 'regule_mode'; 
witnessInfo.param{10}            =  regul_mode; 

witnessInfo.param_name{11}      = 'objective_function'; 
witnessInfo.param{11}           =  zeros(1, nIter_max); 

witnessInfo.param_name{12}      = 'data_fidelity_term'; 
witnessInfo.param{12}           =  zeros(1, nIter_max); 

witnessInfo.param_name{13}      = 'regule_term'; 
witnessInfo.param{13}           =  zeros(1, nIter_max); 

end

