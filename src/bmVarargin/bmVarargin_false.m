% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmVarargin_false(varargin)

for i = 1:nargout
    if isempty(varargin{i})
        varargout{i} = false; 
    else
        varargout{i} = varargin{i}; 
    end
end

end