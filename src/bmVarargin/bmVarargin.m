function varargout = bmVarargin(varargin)
% varargout = bmVarargin(varargin)
%
% This function is replacing ungiven input parameters for a function with
% empty vectors []. This is a custom way to handle default valued, variable
% sizeinput parameters
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   varargin (cell array): Contains any kind of arguments which are to 
%    be distributed to the given outputs. Can be empty
%
% Returns:
%   varargout (cell array): Contains Any kind of variables to be filled 
%    with values from varargin or to be initialized with an empty vector.
%
% Examples:
%   argSize = bmVarargin(varargin);
%   [var1, var2, var3] = bmVarargin(varargin); 
%   var1 = bmVarargin();

myCell = [];
% By default varargin is a cell array
% if varargin is given then varargin is read into myCell
if length(varargin) > 0
    myCell = varargin{1}; 
end

% Fill in the outputs with arguments given (varargin not empty)
myCount = 0;
for i = 1:length(myCell)
    myCount = myCount + 1;
    varargout{i} = myCell{i};
end

% Set to default value [] to all outputs for which the arguments were not 
% given
for i = myCount+1:nargout
    varargout{i} = [];
end

end