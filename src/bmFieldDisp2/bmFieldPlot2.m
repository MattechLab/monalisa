% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% autoScaleFlag can be left empty. The default value is false. 
%
% normMax can be left empty. The default value is inf.  
%
% varargin{1} : argImage, can be left empty. 
%   If it is not, the image is shown in
%   background of the field. 

function bmFieldPlot2(x, y, vx, vy, argSize, autoScaleFlag, normMax, varargin)

argSize = argSize(:)'; 

if isempty(autoScaleFlag)
    autoScaleFlag = false; 
end

if isempty(normMax)
    normMax = inf; 
end

argImage = []; 
if length(varargin) > 0
    argImage = varargin{1}; 
end

if isempty(x) && isempty(y)
    x = 1:argSize(1, 1);
    y = 1:argSize(1, 2);
    [x, y] = ndgrid(x, y);
end

if isempty(argImage)
    bmFieldPlot2_noImage(x, y, vx, vy, argSize, autoScaleFlag, normMax);    
else
    bmFieldPlot2_image(x, y, vx, vy, autoScaleFlag, normMax, argImage);
end

