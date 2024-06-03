% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmSparseMat_r_nJump2index(r_nJump)

l_size = int32(size(r_nJump(:)', 2)); 
r_nJump_32 = int32(r_nJump(:)); 
r_nJump_64 = int64(r_nJump(:)); 
out_length = int64(sum(r_nJump_64, 'native')); 



[out, int64_check] = bmSparseMat_r_nJump2index_mex(l_size, r_nJump_32, out_length); 
out = out+1; % c++ index to matlab index

if ~isequal(int64_check, out_length) || ~strcmp(class(int64_check), 'int64')
    myErrorString = ['In bmSparseMat_r_nJump2index_mex : it seems that the ', ...
                     'convertion from int64 to mwSize failed. Eventually ', ... 
                     'use ''-largeArrayDims'' when compiling with mex. ']; 
    error(myErrorString); 
end


end