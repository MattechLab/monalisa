function out = bmVoronoi(x, varargin)
% out = bmVoronoi(x, varargin)
%
% This function makes use of the 'voronoin' and 'conhulln' functions
% of matlab to calculate the area or volume from a list of seed points.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   x (array): Contains the seeds from which the Voronoi cell is
%    calculated. Must be of size p x nPt, where nPt is the number of
%    positions in the p-dimensional space. p can be 1,2 or 3.
%    varargin: Can contain bool for the dispFlag to print the end of the
%    calculations
%
% Returns:
%   out (list): Contains Voronoi volume or area calculated from x and is of
%   size [1, nPt]. Contains -1 at indexes where the values are invalid
%    (should be filtered out afterwards).
%
% Note:
%   The trajectory x must be separated i.e. the list of positions 
%   contained in x must be a list of pairwise different positions.
%
%   After 'voronoin' and 'convhulln', the problematic volume elements have
%   to be replaced by a realistic value. This is done by one of the
%   bmVoronoi_replace_vXXX function, the choice being specified
%   by the string replaceVersion given in varargin.

% initial -----------------------------------------------------------------
x = double(x);

imDim = size(x, 1);
nPt = size(x, 2);
out = zeros(1, nPt); % Row vector for volume / area

dispFlag = true;
if length(varargin) > 0
    dispFlag = varargin{1};
end
% END_initial -------------------------------------------------------------

% voronoi -----------------------------------------------------------------
if (size(x, 1) == 1) % special implementation for 1Dim case.
    out = bmVolumeElement1(x);
    % for the 1Dim case, the program is finished here.
    return; 
    
elseif (size(x, 1) == 2) || (size(x, 1) == 3) % voronoi for 2Dim and 3Dim.
    if dispFlag
        disp('Running ''voronoin'' and ''convhulln''... can take some time ...');
    end
    % Returns all vertices and a cell array defining every Voronoi cell by
    % indexing (row) the vertices. The cells are calculated from the
    % seedpoints x
    [v,c] = voronoin(x'); 
end
% END_voronoi -------------------------------------------------------------



% convex hull -------------------------------------------------------------
for j = 1:nPt
    % We cannot compute the volume of a polyedre with a vertex at infinity.
    if all(c{j} ~= 1) 
        myVertices = v(c{j},:);
        try
            % Calculate volume / area of convex hull created from vertices
            % Maybe use convhull as dim is only 2 or 3 (more efficient)
            [~, out(1, j)] = convhulln(myVertices); 
        catch myErrorMsg
            out(1, j) = -1; % Indicate problem with vertices
        end
    else
        out(1, j) = -1; % Indicate problem with vertices
    end
end
if dispFlag
    disp('... ''voronoin'' and ''convhulln'' done !');
end
% END_convex hull ---------------------------------------------------------

end