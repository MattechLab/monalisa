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
% by the string replaceVersion given in varargin.


function out = bmVoronoi(x, varargin)

% initial -----------------------------------------------------------------
x = double(x);

imDim = size(x, 1);
nPt = size(x, 2);
out = zeros(1, nPt);

dispFlag = true;
if length(varargin) > 0
    dispFlag = varargin{1};
end
% END_initial -------------------------------------------------------------

% voronoi -----------------------------------------------------------------
if (size(x, 1) == 1) % special implementation for 1Dim case.
    out = bmVolumeElement1(x);
    return; % for the 1Dim case, the program is finished here.
    
elseif (size(x, 1) == 2) || (size(x, 1) == 3) % voronoi for 2Dim and 3Dim.
    if dispFlag
        disp('Running ''voronoin'' and ''convhulln''... can take some time ...');
    end
    [v,c] = voronoin(x');
end
% END_voronoi -------------------------------------------------------------



% convex hull -------------------------------------------------------------
for j = 1:nPt
    if all(c{j} ~= 1) % We cannot compute the volume of a polyedre with a vertex at infinity.
        myVertices = v(c{j},:);
        try
            [~, out(1, j)] = convhulln(myVertices);
        catch myErrorMsg
            out(1, j) = -1;
        end
    else
        out(1, j) = -1;
    end
end
if dispFlag
    disp('... ''voronoin'' and ''convhulln'' done !');
end
% END_convex hull ---------------------------------------------------------

end