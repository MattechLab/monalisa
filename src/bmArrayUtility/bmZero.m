% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


% varargin is the size of the cell array, in case we want the output z to
% be a cell array. 

function z = bmZero(argSize, argType, varargin)

frame_size = bmVarargin(varargin); 
if ~isempty(frame_size)
    z = cell(frame_size);
    z = z(:);
    for i = 1:size(z(:), 1)
        z{i} = bmZero(argSize, argType);
    end
    z = reshape(z, frame_size);
    return;
end

z = []; 
if strcmp(argType, 'real_double')
    z = zeros(argSize, 'double'); 
elseif strcmp(argType, 'complex_double')
    z = complex(zeros(argSize, 'double'), zeros(argSize, 'double'));
elseif strcmp(argType, 'real_single')
    z = zeros(argSize, 'single'); 
elseif strcmp(argType, 'complex_single')
    z = complex(zeros(argSize, 'single'), zeros(argSize, 'single'));
end

end