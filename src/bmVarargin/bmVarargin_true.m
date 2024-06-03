% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmVarargin_true(varargin)

for i = 1:nargout
    if isempty(varargin{i})
        varargout{i} = true; 
    else
        varargout{i} = varargin{i}; 
    end
end

end