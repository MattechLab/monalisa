% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmSparseMat_matlabSparse2bmMultipleSparseMat(ms, i, matlabSparseMat, N_u, d_u, kernelType, nWin, kernelParam)

size_1 = size(matlabSparseMat, 1); 
size_2 = size(matlabSparseMat, 2); 

matlabSparseMat = matlabSparseMat';

[ind_1, ind_2, m_val] = find(matlabSparseMat);
myHist = histcounts(ind_2, [1:size_1+1]-0.5);

r_ind = ind_1(:)'; 
m_val = m_val(:)'; 
r_nJump = myHist(:)';  




ms.r_size{i}            = int32(size_2);
ms.l_size{i}            = int32(size_1);
ms.l_nJump{i}           = int32(size_1);

ms.r_nJump{i}           = int32(r_nJump);
ms.r_ind{i}             = int32(r_ind);
ms.m_val{i}             = single(m_val);

ms.N_u{i}               = int32(N_u); 
ms.d_u{i}               = single(d_u); 
ms.kernel_type{i}       = kernelType; 
ms.nWin{i}              = int32(nWin); 
ms.kernelParam{i}       = single(kernelParam); 

ms.block_type{i}        = 'void'; 
ms.type{i}              = 'matlab_ind';
ms.l_squeeze_flag{i}    = false; 

end
