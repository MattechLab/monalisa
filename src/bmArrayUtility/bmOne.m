% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myOne = bmOne(argSize, argType)

myOne = []; 
if strcmp(argType, 'real_double')
    myOne = ones(argSize, 'double'); 
elseif strcmp(argType, 'complex_double')
    myOne = complex(ones(argSize, 'double'), zeros(argSize, 'double'));
elseif strcmp(argType, 'real_single')
    myOne = ones(argSize, 'single'); 
elseif strcmp(argType, 'complex_single')
    myOne = complex(ones(argSize, 'single'), zeros(argSize, 'single'));
end

end