% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function s = bmBinary2Array_sparseMat(argDir)

s = bmSparseMat; 

myCell    = textread([argDir, '/bmArray2Binary_sparseMat_header.txt'], '%s'); 

s.type    = myCell{1}; 

if strcmp(s.type, 'matlab_ind') || strcmp(s.type, 'l_squeezed_matlab_ind')
    
    s.block_type    = myCell{2}; 
    s.kernel_type   = myCell{3}; 
    s.r_size        = int32(str2num(myCell{4}));
    s.l_size        = int32(str2num(myCell{5}));
    s.l_nJump       = int32(str2num(myCell{6}));    
    
    s.r_nJump       = bmBinary2Array(argDir, 'r_nJump');
    s.r_ind         = bmBinary2Array(argDir, 'r_ind');
    s.m_val         = bmBinary2Array(argDir, 'm_val');
    s.l_ind         = bmBinary2Array(argDir, 'l_ind');
    s.N_u           = bmBinary2Array(argDir, 'N_u');
    s.d_u           = bmBinary2Array(argDir, 'd_u');
    s.nWin          = bmBinary2Array(argDir, 'nWin');
    s.kernelParam   = bmBinary2Array(argDir, 'kernelParam');
    
elseif strcmp(s.type, 'cpp_prepared') || strcmp(s.type, 'l_squeezed_cpp_prepared')
    
    s.block_type    = myCell{2}; 
    s.kernel_type   = myCell{3}; 
    s.r_size        = int32(str2num(myCell{4}));
    s.l_size        = int32(str2num(myCell{5}));
    s.l_nJump       = int32(str2num(myCell{6}));
    s.nBlock        = int64(str2num(myCell{7}));
    
    s.r_nJump       = bmBinary2Array(argDir, 'r_nJump');
    s.r_jump        = bmBinary2Array(argDir, 'r_jump');
    s.m_val         = bmBinary2Array(argDir, 'm_val');
    s.l_jump        = bmBinary2Array(argDir, 'l_jump');
    s.N_u           = bmBinary2Array(argDir, 'N_u');
    s.d_u           = bmBinary2Array(argDir, 'd_u');
    s.nWin          = bmBinary2Array(argDir, 'nWin');
    s.kernelParam   = bmBinary2Array(argDir, 'kernelParam');
    
    s.block_length  = bmBinary2Array(argDir, 'block_length'); 
    s.l_block_start = bmBinary2Array(argDir, 'l_block_start');
    s.m_block_start = bmBinary2Array(argDir, 'm_block_start');
    
end





end