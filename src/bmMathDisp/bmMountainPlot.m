% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function take an n-times-m matrix M as argument and plot the 
% corresponding surfaceplot. 

function bmMountainPlot(M, varargin)

M = double(M);

if length(varargin) > 1
    x = varargin{1}; 
    y = varargin{2}; 
else
    [iMax, jMax] = size(M);
    x = 1:iMax; 
    y = 1:jMax; 
end

[X, Y]  = ndgrid(x, y);

% figure
mesh(X, Y, M, 'FaceAlpha', 0)


end
