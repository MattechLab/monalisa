% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function make use of the 'voronoin' and 'conhulln' functions 
% of matlab.
%
% x must be p-times-nPt where nPt is the number of position in the p-Dim 
% space.
%
% warning : the trajectory x must be separated i.e. the list of
% positions contained in x must be a list of pairwise different positions.
%
% After 'voronoin' and 'convhulln', the problematic volume elements have 
% to be replaced by a realistic value. This is done by one of the 
% bmVoronoi_replace_vXXX function, the choice being specified 
% by the string voronoiVersion given in varargin. 


function out = bmVoronoi(x)

% initial -----------------------------------------------------------------
x = double(x);

imDim = size(x, 1); 
nPt = size(x, 2); 
out = zeros(1, nPt);

% END_initial -------------------------------------------------------------

% voronoi -----------------------------------------------------------------
if (size(x, 1) == 1) % special implementation for 1Dim case. 
    [mySort, myPerm] = sort(x);
    [~, myInvPerm] = sort(myPerm);
    myMid = (mySort(2:end) + mySort(1:end-1))/2;
    myMid = [mySort(1) - (myMid(1) - mySort(1)), myMid, mySort(end) + (mySort(end) - myMid(end))];
    myDiff = myMid(2:end) - myMid(1:end-1);
    out = myDiff(myInvPerm);
    return; % for the 1Dim case, the program is finished here.
    
elseif (size(x, 1) == 2) || (size(x, 1) == 3) % voronoi for 2Dim and 3Dim. 
    disp('Running ''voronoin'' and ''convhulln''... can take some time ...');
    [v,c] = voronoin(x');
end
% END_voronoi -------------------------------------------------------------

% convex hull -------------------------------------------------------------



% For 2 Dim test ----------------------------------------------------------
figure
hold on
plot(x(1,:), x(2,:), 'r.', 'Markersize', 10);
% END_For 2 Dim test ------------------------------------------------------

% for 3D ------------------------------------------------------------------
% figure
% hold on
% plot3(x(1, :), x(2, :), x(3, :), 'b.', 'Markersize', 10);
% END_for 3D --------------------------------------------------------------

for j = 1:nPt    
    if all(c{j} ~= 1) % We cannot compute the volume of a polyedre with a vertex at infinity.
        myVertices = v(c{j},:); 
        try
            [~, out(1, j)] = convhulln(myVertices);
        catch myErrorMsg
            out(1, j) = -1;
        end
        
%         % Plot for 2 Dim test ---------------------------------------------
        patch(myVertices(:,1), myVertices(:,2), rand);
        alpha(0.2);
%         % End of the plot -------------------------------------------------
        
%        Plot for 3 Dim test ---------------------------------------------
%         figure
%         hold on
%         plot3(x(1, j), x(2, j), x(3, j), 'r.', 'Markersize', 10);
%         myConvHull = convhulln(myVertices); 
%         myDelaunay = delaunayn(myVertices); 
%         for i = 1:size(myConvHull, 1)
%             myTriangle = [myVertices(myConvHull(i,1), :);  myVertices(myConvHull(i,2), :); myVertices(myConvHull(i,3), :)];
%             patch(myTriangle(:,1), myTriangle(:,2), myTriangle(:,3), [rand rand rand] );
%             alpha(0.2)
%         end
%        title(['Volume = ' num2str(out(j))] )
        axis image
%        uiwait
        % End of the plot -------------------------------------------------

        
    else
        out(1, j) = -1;
    end
end
disp('... ''voronoin'' and ''convhulln'' done !');
% END_convex hull ---------------------------------------------------------




end