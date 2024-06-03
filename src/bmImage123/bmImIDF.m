% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function iFf = bmImIDF(argIm, varargin)

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

myDim = bmImDim(argIm);

if myDim == 1
    iFf = bmIDF(argIm, 1, nZero_x, 1);
    iFf = iFf/size(argIm, 1);
elseif myDim == 2
    iFf = bmIDF(argIm, 1, nZero_x, 1);
    iFf = bmIDF(  iFf, 1, nZero_y, 2);
    iFf = iFf/size(argIm, 1);
    iFf = iFf/size(argIm, 2);
elseif myDim == 3
    iFf = bmIDF(argIm, 1, nZero_x, 1);
    iFf = bmIDF(  iFf, 1, nZero_y, 2);
    iFf = bmIDF(  iFf, 1, nZero_z, 3);
    iFf = iFf/size(argIm, 1);
    iFf = iFf/size(argIm, 2);
    iFf = iFf/size(argIm, 3);
end


end