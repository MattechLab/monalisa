function out = bmSparseMat_r_nJump2index(r_nJump)
% out = bmSparseMat_r_nJump2index(r_nJump)
%
% This function expands the input array into indices based on the number of 
% grid points repeated for each point, using a mex function to efficiently 
% do this in c++.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   r_nJump (array): Contains for each point the number of points in the
%   second dimension (grid), the number of indices jumped in a flattened 
%   array to get to the next point.
%
% Returns:
%   out (array): Contains a list that repeats r_njJump(index) times the 
%   corresponding index in r_nJump for every point / index and is of size 
%   sum(r_nJump).
%
% Examples:
%   out = bmSparseMat_r_nJump2index([3, 1, 0, 2])
%       out = [1, 1, 1, 2, 4, 4]
%
%   out = bmSparseMat_r_nJump2index([0, 0, 0, 10, 0, 10])
%       out = [4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6]
%
% Notes:
%   bmSparseMat_r_nJump2index is the inverse operation of
%   histcounts(out, (1:size(r_nJump, 2) + 1) - 0.5)

 % Get length of flattened array
l_size = int32(size(r_nJump(:)', 2));

% Convert array to int types for c++ processing
r_nJump_32 = int32(r_nJump(:));
r_nJump_64 = int64(r_nJump(:)); 

% Get total number of jumps by summing
out_length = int64(sum(r_nJump_64, 'native')); 


% This mex function fills an output array by repeating r_nJump_32(index) 
% times the index, for every index 0 to l_size-1
% Example: r_nJump_32 = [3,1,0,2] gives l_size = 4, and out_length = 6.
%   The result of the function is out = [0,0,0,1,3,3] (c++ indices)
[out, int64_check] = bmSparseMat_r_nJump2index_mex(l_size, r_nJump_32, out_length); 

% c++ index (zero-based) to matlab index (one-based)
out = out+1; 

% Check if computation resulted in a valid output (conversion worked)
if ~isequal(int64_check, out_length) || ~strcmp(class(int64_check), 'int64')
    myErrorString = ['In bmSparseMat_r_nJump2index_mex : it seems that the ', ...
                     'convertion from int64 to mwSize failed. Eventually ', ... 
                     'use ''-largeArrayDims'' when compiling with mex. ']; 
    error(myErrorString); 
end


end