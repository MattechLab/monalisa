% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function z = bmRand(argSize, argType)

z = []; 
if strcmp(argType, 'real_double')
    z = rand(argSize, 'double'); 
elseif strcmp(argType, 'complex_double')
    z = complex(rand(argSize, 'double'), rand(argSize, 'double'));
elseif strcmp(argType, 'real_single')
    z = rand(argSize, 'single'); 
elseif strcmp(argType, 'complex_single')
    z = complex(rand(argSize, 'single'), rand(argSize, 'single'));
end

end