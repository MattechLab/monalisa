% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function can be called in two ways
%
% outIm = bmImInterp2(argIm, argMethod, argGridX2, argGridY2)
%
% or
%
% outIm = bmImInterp(argIm, method, argGridX, argGridY, argGridX2, argGridY2);
%
%'method' is the interpolation method, for example 'spline' or 'cubic'
% or 'linear' or ....
%
% argGridX and argGridY must have been created with ndgrid,
% it cannot be a non-cartesian grid.
%
% argGridX2 and argGridY2 can be arbitraty but paired.

function out = bmInterp2(argIm, argMethod, varargin)

argSize = size(argIm);
argSize = argSize(:)';

if size(argSize, 2) > 3
    error('In bmInterp2 : the input image must be 2 or 3 dimensional. ');
    return;
end

if size(argSize, 2) == 3
    argSize_1 = argSize(1, 1);
    argSize_2 = argSize(1, 2);
    argSize_3 = argSize(1, 3);
else
    argSize_1 = argSize(1, 1);
    argSize_2 = argSize(1, 2);
    argSize_3 = 1;
end

if (nargin == 4) || (nargin == 5)
    
    x2 = varargin{1};
    x2 = x2(:);
    
    y2 = varargin{2};
    y2 = y2(:);
    
    out = zeros(size(x2, 1), argSize_3); 


    for i = 1:argSize_3
        out(:, i) = interpn(argIm(:, :, i), x2, y2, argMethod);
    end
    
    
elseif (nargin == 6) || (nargin == 7)
    
    x = varargin{1};
    x = reshape(x, [argSize_1, argSize_2]);
    
    y = varargin{2};
    y = reshape(y, [argSize_1, argSize_2]);
    
    x2 = varargin{3};
    x2 = x2(:);
    
    y2 = varargin{4};
    y2 = y2(:);
    
    out = zeros(size(x2, 1), argSize_3); 
    
    for i = 1:argSize_3
        out(:, i) = interpn(x, y, argIm(:, :, i), x2, y2, argMethod);
    end
    
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