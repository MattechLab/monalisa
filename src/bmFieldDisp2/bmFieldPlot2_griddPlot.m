% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmFieldPlot2_griddPlot(argX, argY, varargin)

if length(varargin) > 0
    myString = varargin{1};
else
    myString = '.';
end

if length(varargin) > 1
    myMarkerSize = varargin{2};
else
    myMarkerSize = 20;
end

x = argY;
y = argX;


plot(x(:), y(:), myString, 'Markersize', myMarkerSize);
set(gca, 'XDir', 'normal');
set(gca, 'YDir', 'reverse');
axis image;


end