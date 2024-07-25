% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmVarargin(varargin)
% This function is replacing ungiven input parameters for a function with
% empty vectors []. This is a custom way to handle default valued, variable
% sizeinput parameters
myCell = [];
% By default varargin is a cell array
% if varargin is given then varargin is read into myCe
if length(varargin) > 0
    myCell = varargin{1}; 
end

myCount = 0;
for i = 1:length(myCell)
    myCount = myCount + 1;
    varargout{i} = myCell{i};
end
% Set to default value [] to all the rest of argument not given
for i = myCount+1:nargout
    varargout{i} = [];
end

end