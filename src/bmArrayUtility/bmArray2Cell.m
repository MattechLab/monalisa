% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function c = bmArray2Cell(a, N_u)

nDim_array = size(N_u(:), 1); 
a_size  = size(a); 

in_size = a_size(1:nDim_array);
in_length = prod(in_size(:)); 

c_size  = a_size(nDim_array+1:end); 

if (size(c_size, 2) == 1)
    c_size = [c_size, 1]; 
end

c_length = prod(c_size(:)); 

a = reshape(a, [in_length, c_length]); 

c = cell(c_length, 1); 
for i = 1:c_length
   c{i} =  reshape(a(:, i), in_size); 
end

c = reshape(c, c_size); 

end