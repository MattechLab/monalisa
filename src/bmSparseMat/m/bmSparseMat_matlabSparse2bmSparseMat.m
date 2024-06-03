% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function b = bmSparseMat_matlabSparse2bmSparseMat(a, N_u, d_u, kernelType, nWin, kernelParam)

size_1 = size(a, 1); 
size_2 = size(a, 2); 

a = a';

[ind_1, ind_2, m_val] = find(a);
myHist = histcounts(ind_2, [1:size_1+1]-0.5);

r_ind = ind_1(:)'; 
m_val = m_val(:)'; 
r_nJump = myHist(:)';  

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
