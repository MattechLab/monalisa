% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function a = bmCell2Array(c)

c_size = size(c);
c_length = prod(c_size(:)); 
c = c(:); 

in_size = size(c{1}); 
in_length = prod(in_size(:)); 

a_size = [in_length, c_length]; 


if isa(c{1}, 'double') & isreal(c{1})
    a = zeros(a_size, 'double');
elseif isa(c{1}, 'double') & not(isreal(c{1}))
    a = zeros(a_size, 'double');
    a = complex(a, a);
elseif isa(c{1}, 'single') & isreal(c{1})
    a = zeros(a_size, 'single');
elseif isa(c{1}, 'single') & not(isreal(c{1}))
    a = zeros(a_size, 'single');
    a = complex(a, a); 
end

for i = 1:c_length
    temp_a = c{i}; 
    a(:, i) = temp_a(:); 
end

a = reshape(a, [in_size, c_size]); 

end