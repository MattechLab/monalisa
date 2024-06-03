% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function can be called in two ways
%
% outIm = bmInterp3(argIm, argMethod, argGridX2, argGridY2, argGridZ2)
%
% or
%
% outIm = bmInterp3(argIm, method, argGridX, argGridY, argGridZ, argGridX2, argGridY2, argGridZ2);
%
%'method' is the interpolation method, for example 'spline' or 'cubic'
% or 'linear' or ... see matlab doc. 
%
% argGridX and argGridY and argGridZ must have been created with ndgrid,
% it cannot be a non-cartesian grid.
%
% argGridX2 and argGridY2 and argGridZ2 can be arbitraty but paired 
% two by two.

function out = bmInterp3(argIm, argMethod, varargin)

argSize = size(argIm);
argSize = argSize(:)';

if size(argSize, 2) ~= 3 
    error('In bmInterp3 : the input image must be 3 dimensional. ');
    return;
end


argSize_1 = argSize(1, 1);
argSize_2 = argSize(1, 2);
argSize_3 = argSize(1, 3);

    
if (nargin == 5) || (nargin == 6)
    
    x2 = varargin{1};
    x2 = x2(:);
    
    y2 = varargin{2};
    y2 = y2(:);
    
    z2 = varargin{3};
    z2 = z2(:);

    out = interpn(argIm, x2, y2, z2, argMethod); 
    
elseif (nargin == 8) || (nargin == 9)
    
    x = varargin{1};
    x = reshape(x, [argSize_1, argSize_2, argSize_3]);
    
    y = varargin{2};
    y = reshape(y, [argSize_1, argSize_2, argSize_3]);
    
    z = varargin{3};
    z = reshape(z, [argSize_1, argSize_2, argSize_3]);
    
    x2 = varargin{4};
    x2 = x2(:);
    
    y2 = varargin{5};
    y2 = y2(:);
    
    z2 = varargin{6};
    z2 = z2(:);
    
    
    out = interpn(x, y, z, argIm, x2, y2, z2, argMethod);
    
    
end

if strcmp(varargin{end}, 'reshape')
    out = reshape(out, [argSize_1, argSize_2, argSize_3]); 
end

out(isnan(out)) = 0; 

if  isa(argIm, 'single')
    out = single(out);
elseif isa(argIm, 'double')
    out = double(out);
end


end