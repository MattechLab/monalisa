% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmArray2Binary_sparseMat(s, argDir)

if strcmp(s.type, 'void')
   error('The sparseMat object is of type ''void ''.'); 
   return; 
end

mkdir(argDir); 

myFile = [argDir, '/bmArray2Binary_sparseMat_header.txt']; 

type_string         = s.type;
block_type_string   = s.block_type; 
kernel_type_string  = s.kernel_type;  
r_size_string       = num2str(s.r_size); 
l_size_string       = num2str(s.l_size);
l_nJump_string      = num2str(s.l_nJump); 
nBlock_string       = num2str(s.nBlock); 


if strcmp(s.type, 'matlab_ind') || strcmp(s.type, 'l_squeezed_matlab_ind')

    bmArray2Binary(s.r_nJump,       argDir, 'r_nJump',      'int');
    bmArray2Binary(s.r_ind,         argDir, 'r_ind',        'int');
    bmArray2Binary(s.m_val,         argDir, 'm_val',        'single');
    bmArray2Binary(s.l_ind,         argDir, 'l_ind',        'int');
    bmArray2Binary(s.N_u,           argDir, 'N_u',          'int');
    bmArray2Binary(s.d_u,           argDir, 'd_u',          'single');
    bmArray2Binary(s.nWin,          argDir, 'nWin',         'int');
    bmArray2Binary(s.kernelParam,   argDir, 'kernelParam',  'single');
    
    dlmwrite(myFile, type_string,                   'delimiter', '', 'newline','pc');
    dlmwrite(myFile, block_type_string,  '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, kernel_type_string, '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, r_size_string,      '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, l_size_string,      '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, l_nJump_string,     '-append', 'delimiter', '', 'newline','pc');
    
elseif strcmp(s.type, 'cpp_prepared') || strcmp(s.type, 'l_squeezed_cpp_prepared')
    
    bmArray2Binary(s.r_nJump,       argDir, 'r_nJump',      'int');
    bmArray2Binary(s.r_jump,        argDir, 'r_jump',       'int');
    bmArray2Binary(s.m_val,         argDir, 'm_val',        'single');
    bmArray2Binary(s.l_jump,        argDir, 'l_jump',       'int');
    bmArray2Binary(s.N_u,           argDir, 'N_u',          'int');
    bmArray2Binary(s.d_u,           argDir, 'd_u',          'single');
    bmArray2Binary(s.nWin,          argDir, 'nWin',         'int');
    bmArray2Binary(s.kernelParam,   argDir, 'kernelParam',  'single');
    
    bmArray2Binary(s.block_length,  argDir, 'block_length',  'int'); 
    bmArray2Binary(s.l_block_start, argDir, 'l_block_start', 'int');
    bmArray2Binary(s.m_block_start, argDir, 'm_block_start', 'int64');    
    
    dlmwrite(myFile, type_string,                   'delimiter', '', 'newline','pc');
    dlmwrite(myFile, block_type_string,  '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, kernel_type_string, '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, r_size_string,      '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, l_size_string,      '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, l_nJump_string,     '-append', 'delimiter', '', 'newline','pc');
    dlmwrite(myFile, nBlock_string,      '-append', 'delimiter', '', 'newline','pc');
    
end


end
