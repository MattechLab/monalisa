function b = bmSparseMat_matlabSparse2bmSparseMat(a, N_u, d_u, kernelType, nWin, kernelParam)
% b = bmSparseMat_matlabSparse2bmSparseMat(a, N_u, d_u, kernelType, nWin, kernelParam)
%
% This function creates a object of class bmSparseMat, fills it out with
% the given arguments and returns the object.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   a (sparse matrix): Main sparse matrix of size [prod(N_u), NPt], where
%   NPt is the number of points in the trajectory.
%   N_u (list): Contains the number of points in the grid in each
%   dimension.
%   d_u (lits): Contains the distance between the grid points in each
%   dimension.
%   kernelType (char): Kernel type for the gridding.
%   nWin (int): Window-width for the gridding.
%   kernelParam (list): Kernel parameters corresponding to the kernel type.
%
% Returns:
%   b (bmSparseMat): Object filled in with the given parameters


size_1 = size(a, 1); % Nb of rows
size_2 = size(a, 2); % Nb of columns

a = a';

% Find all non zero entries, ind_2 (col) is sorted from 1 to max(ind_2), 
% which should be size_1 (due to transpose)
[ind_1, ind_2, m_val] = find(a); 

% Bin column indices into histogram (row indices before transpose -> 
% size_1) with edges defined. Bins contain number of non zero indicies for
% each row in a (column in a'). Inverse operation of
% bmSparseMat_r_nJump2index.m
myHist = histcounts(ind_2, (1:size_1+1)-0.5); 

% Change to row vector
r_ind = ind_1(:)'; 
m_val = m_val(:)'; 
r_nJump = myHist(:)';  

% Create bmSparseMat and fill in values
b = bmSparseMat;

b.r_size  = int32(size_2);
b.l_size  = int32(size_1);
b.l_nJump = int32(size_1);

b.r_nJump = int32(r_nJump);
b.r_ind   = int32(r_ind);
b.m_val   = single(m_val);

b.N_u           = int32(N_u); 
b.d_u           = single(d_u); 
b.kernel_type   = kernelType; 
b.nWin          = int32(nWin); 
b.kernelParam   = single(kernelParam); 

b.block_type        = 'void'; 
b.type              = 'matlab_ind';
b.l_squeeze_flag    = false; 

end
