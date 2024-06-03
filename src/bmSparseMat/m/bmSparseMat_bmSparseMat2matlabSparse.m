% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function b = bmSparseMat_bmSparseMat2matlabSparse(a)

if not(strcmp(a.type, 'matlab_ind'))
    error('The type of the bmSparseMat must be ''matlab_ind''. ');
    return; 
end

size_1 = double(a.l_size); 
size_2 = double(a.r_size); 
n_jump = double(a.r_nJump); 
r_ind  = double(a.r_ind); 
m_val  = double(a.m_val); 

l_ind  = double(bmSparseMat_r_nJump2index(n_jump));  


b = sparse(r_ind(:), l_ind(:), m_val(:));
b = b'; 


if size(b, 2) < a.r_size
    temp_sparse = sparse(size(b, 1), double(a.r_size - size(b, 2))) ;
    b = cat(2, b, temp_sparse); 
end

if size(b, 1) < a.l_size
    temp_sparse = sparse(double(a.l_size - size(b, 1)), size(b, 2));
    b = cat(1, b, temp_sparse); 
end



end

