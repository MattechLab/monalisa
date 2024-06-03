% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmVarargin(varargin)

myCell = []; 
if length(varargin) > 0
    myCell = varargin{1}; 
end

myCount = 0;
for i = 1:length(myCell)
    myCount = myCount + 1;
    varargout{i} = myCell{i};
end

for i = myCount+1:nargout
    varargout{i} = [];
end

end