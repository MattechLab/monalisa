% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% argLines must have the size [2 or 3, npt, nseg*nshot]. It is the format
% lineOfPoint. 

function out = bmLineListPlot(argLines, argLinAssym, varargin)

myLines = argLines;

myColor = 'k';
if length(varargin) > 0
    myColor = varargin{1};
end

L_flag = false;
L = 2;
if length(varargin) > 1
    if isnumeric(varargin{2}) && not(isempty(varargin{2}))
        L = varargin{2};
        L_flag = true;
    end
end

if length(varargin) > 2
    if  strcmp(varargin{3}, 'figure')
        figure;
    end
end
axis(gca);
hold on

if argLinAssym == 0
    midPointNum =  ceil(size(argLines, 2)/2);
elseif argLinAssym == 1
    midPointNum = size(argLines, 2)/2;
elseif argLinAssym == 2
    midPointNum = size(argLines, 2)/2 + 1;
end

if size(argLines, 1) == 2
    
    for i = 1:size(myLines, 3)
        plot(myLines(1,:,i), myLines(2,:,i), ['.-', myColour]);
        
        p0 = [myLines(1,1,i) myLines(2,1,i)];
        p1 = [myLines(1,end,i), myLines(2,end,i)];
        v0 = (p1-p0)/norm(p1-p0);
        p3 = p0 - v0*(v0*p0');
        myDirection = p3 + v0*min(L*0.8, norm(p1-p3));
        plot(myDirection(1), myDirection(2), '.', 'Color', 'magenta', 'Markersize', 14);
        
        myLength = size(myLines, 2);
        plot(myLines(1, midPointNum,i), myLines(2, midPointNum,i), '.', 'Color', 'red', 'Markersize', 14);
    end
    
    plot([-L L], [0 0], '-r');
    plot([0 0], [-L L], '-g');
    
    plot(L, 0, '.r');
    plot(0, L, '.g');
    
    
    axis([-L L -L L])
    
    xlabel('X')
    ylabel('Y')
    
elseif size(argLines, 1) == 3
    
    for i = 1:size(myLines, 3)
        plot3(myLines(1,:,i), myLines(2,:,i), myLines(3,:,i), ['.-', myColor]);
        
        p0 = [myLines(1,1,i) myLines(2,1,i) myLines(3,1,i)];
        p1 = [myLines(1,end,i) myLines(2,end,i) myLines(3,end,i)];
        v0 = (p1-p0)/norm(p1-p0);
        p3 = p0 - v0*(v0*p0');
        myDirection = p3 + v0*min(L*0.8, norm(p1-p3));
        plot3(myDirection(1), myDirection(2), myDirection(3), '.', 'Color', 'magenta', 'Markersize', 14);
        
        myLength = size(myLines, 2);
        plot3(myLines(1, midPointNum,i), myLines(2, midPointNum,i), myLines(3, midPointNum,i), '.', 'Color', 'red', 'Markersize', 14);
    end
    
    plot3([-L L], [0 0], [0 0], '-r');
    plot3([0 0], [-L L], [0 0], '-g');
    plot3([0 0], [0 0], [-L L], '-b');
    
    plot3(L, 0, 0, '.r');
    plot3(0, L, 0, '.g');
    plot3(0, 0, L, '.b');
    
    
    axis([-L L -L L -L L])
    
    xlabel('X')
    ylabel('Y')
    zlabel('Z')
    
end

axis image
hold off

end
