function [kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(varargin)
% function [kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(varargin)
%
% This function sets default values for kernelType, nWin and kernelParam
% and checks if given values are valid.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   varargin{1}: Char containing the kernel type. Default value is 'gauss'.
%   varargin{2}: Integer containing the window width. Default value is 3 
%   for 'gauss' and 'kaiser'.
%   varargin{3}: List containing the kernel parameter. Default value is 
%   [0.61, 10] for 'gauss' and [1.95, 10, 10] for 'kaiser'.
%
% Returns:
%   kernelType (char): Kernel type given or default value. Empty if error.
%   nWin (int): Window width given or default value. Empty if error.
%   kernelParam: Kernel parameter given or default value. Empty if error.

% Extract optional arguments
[kernelType, nWin, kernelParam] = bmVarargin(varargin); 

% Set default value for kernelType if empty or wrong type
if isempty(kernelType) || not(isa(kernelType, 'char')) 
    kernelType = 'gauss';
end

% Set default value for nWin if empty, depending on kernel type
if isempty(nWin) 
    if strcmp(kernelType, 'gauss')
        nWin = 3; % magic number
    elseif strcmp(kernelType, 'kaiser')
        nWin = 3; % magic number
    end
end

% Set default value for kernelParam if empty, depending on kernelType
if isempty(kernelParam) 
    if strcmp(kernelType, 'gauss')
        kernelParam = [0.61, 10]; % magic number
        % kernelParam = 0.5; % magic number
    elseif strcmp(kernelType, 'kaiser')
        kernelParam = [1.95, 10, 10]; % magic number
        % kernelParam = [1.6, 10]; % magic number
    end
end

nWin        = double(single(nWin)); 
kernelParam = double(single(kernelParam)); 

% Check if kernelType and kernelParam size match
if strcmp(kernelType, 'gauss') && size(kernelParam(:), 1) == 3
    error('Wrong list of gridding kernel parameters. ');
    kernelType = [];
    nWin = [];
    kernelParam = [];
    % Return empty arrays if error
    return;
end

% Check if kernelType and kernelParam size match
if strcmp(kernelType, 'kaiser') && size(kernelParam(:), 1) == 2
    error('Wrong list of gridding kernel parameters. ');
    kernelType = [];
    nWin = [];
    kernelParam = [];
    % Return empty arrays if error
    return;
end

end
