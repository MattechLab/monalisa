% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% autoScaleFlag can be left empty. The default value is false. 
%
% normMax can be left empty. The default value is inf. 
%
% argImage can be left empty. If it is not, the image is shown in
% background of the field. 

function bmFieldPlot3(x, y, z, vx, vy, vz, argSize, autoScaleFlag, normMax, varargin)

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

if isempty(x) && isempty(y) && isempty(z)
    x = 1:argSize(1, 1);
    y = 1:argSize(1, 2);
    z = 1:argSize(1, 3);
    [x, y, z] = ndgrid(x, y, z);
end
    

if isempty(argImage)
    bmFieldPlot3_noImage(x, y, z, vx, vy, vz, argSize, autoScaleFlag, normMax);    
else
    bmFieldPlot3_image(x, y, z, vx, vy, vz, autoScaleFlag, normMax, argImage);
end

