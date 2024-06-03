% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmPlot(x, y, varargin)

myLineType = '.-';
if length(varargin) > 0
    myLineType = varargin{1};
    if isempty(myLineType) || strcmp(myLineType, 'hold')
        myLineType = '.-';
    end
end

myLineWidth = 2;
if length(varargin) > 1
    myLineWidth = varargin{2};
    if isempty(myLineWidth) || not(isnumeric(myLineWidth))
        myLineWidth = 2;
    end
end

myMarkerSize = 20;
if length(varargin) > 2
    myMarkerSize = varargin{3};
    if isempty(myMarkerSize) || not(isnumeric(myMarkerSize))
        myMarkerSize = 20;
    end
end


myColor = 'b';
if length(varargin) > 3
    myColor = varargin{3};
    if isempty(myColor) || not(ischar(myColor))
        myColor = 'b';
    end
end



notHoldOnFlag = true;
if length(varargin) > 0
    if strcmp(varargin{1}, 'hold') || strcmp(varargin{end}, 'hold')
        notHoldOnFlag = false;
    end
end

if notHoldOnFlag
    figure;
else
    hold on
end


plot(x, y, myLineType, 'Markersize', myMarkerSize, 'Linewidth', myLineWidth, 'Color', myColor);
hold off; 

end