% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [Ff, varargout] = bmImDFT(argIm, varargin)

nZero_x = [];
if length(varargin) > 0
    nZero_x = varargin{1};
end

nZero_y = [];
if length(varargin) > 1
    nZero_y = varargin{2};
end

nZero_z = [];
if length(varargin) > 2
    nZero_z = varargin{3};
end

kx = []; 
ky = []; 
kz = []; 


myDim = bmImDim(argIm);


if myDim == 1
    [Ff, kx] = bmDFT(argIm, 1, nZero_x, 1);
elseif myDim == 2
    [Ff, kx] = bmDFT(argIm, 1, nZero_x, 1);
    [Ff, ky] = bmDFT(   Ff, 1, nZero_y, 2);
elseif myDim == 3
    [Ff, kx] = bmDFT(argIm, 1, nZero_x, 1);
    [Ff, ky] = bmDFT(   Ff, 1, nZero_y, 2);
    [Ff, kz] = bmDFT(   Ff, 1, nZero_z, 3);
end

varargout{1} = kx; 
varargout{2} = ky; 
varargout{3} = kz; 



end