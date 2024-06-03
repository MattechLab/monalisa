% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(varargin)

[kernelType, nWin, kernelParam] = bmVarargin(varargin); 

if isempty(kernelType) || not(isa(kernelType, 'char'))
    kernelType = 'gauss';
end
if isempty(nWin)
    if strcmp(kernelType, 'gauss')
        nWin = 3; % ------------------------------------------------------------ magic
    elseif strcmp(kernelType, 'kaiser')
        nWin = 3; % ------------------------------------------------------------ magic
    end
end
if isempty(kernelParam)
    if strcmp(kernelType, 'gauss')
        kernelParam = [0.61, 10]; % ------------------------------------------------- magic
        % kernelParam = 0.5; % ------------------------------------------------ magic
    elseif strcmp(kernelType, 'kaiser')
        kernelParam = [1.95, 10, 10]; % -------------------------------------------- magic
        % kernelParam = [1.6, 10]; % -------------------------------------------- magic
    end
end

nWin        = double(single(nWin)); 
kernelParam = double(single(kernelParam)); 

if strcmp(kernelType, 'gauss') && size(kernelParam(:), 1) == 3
    error('Wrong list of gridding kernel parameters. ');
    kernelType = [];
    nWin = [];
    kernelParam = [];
    return;
end

if strcmp(kernelType, 'kaiser') && size(kernelParam(:), 1) == 2
    error('Wrong list of gridding kernel parameters. ');
    kernelType = [];
    nWin = [];
    kernelParam = [];
    return;
end

end
