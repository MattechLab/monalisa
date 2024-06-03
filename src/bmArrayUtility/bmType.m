% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myString = bmType(a)

myString = []; 
if isreal(a) & isa(a, 'double')
    myString = 'real_double'; 
elseif not(isreal(a)) & isa(a, 'double')
    myString = 'complex_double';
elseif isreal(a) & isa(a, 'single')
    myString = 'real_single';
elseif not(isreal(a)) & isa(a, 'single')
    myString = 'complex_single';
end

end