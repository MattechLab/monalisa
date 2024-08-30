function varargout = bmTraj2SparseMat(t, v, N_u, dK_u, varargin)
% varargout = bmTraj2SparseMat(t, v, N_u, dK_u, varargin)
%
% This function computes the gridding matrices that allow to map the
% trajectory points onto the new grid and do the inverse. The returned
% matrices are either sparse matrices or objects of the class bmSparseMat,
% depending on the first optional argument.
% 
% Gn = Approximation of inverse -> backward mapping 
% Gu = Forward mapping (grid to trajectory)
% Gut = Transpose of Gu -> backward mapping
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   t (array / cell array): Contains all points of the trajectory.
%   v (array / cell array): Contains the volume elements for each point in 
%    the trajectory. (1, nPt)
%   N_u (list): The size of the cartesian k-space grid on which the 
%    trajectory is regridded.
%   dK_u (list): The distance between the new grid points in the k-space 
%    for every dimension. In the physical sense 1/reconFoV. Same size as
%    N_u.
%   varargin{1}: Char that contains the sparse type. The function returns 
%    objects of class bmSparseMat if it is 'bmSparseMat' or empty and 
%    sparse matrices if anything else. Default value is 'bmSparseMat'.
%   varargin{2}: Char that contains the kernel type. Either 'gauss' or 
%    'kaiser' with 'gauss' being the default value.
%   varargin{3}: Integer that contains the window width. Default value is 3 
%    for 'gauss' and 'kaiser'.
%   varargin{4}: List that contains the kernel parameter. Default value is 
%    [0.61, 10] for 'gauss' and [1.95, 10, 10] for 'kaiser'.
%
% Returns:
%   Gn as varargout{1}: Gn is a normalized sparse matrix or a bmSparseMat, 
%    depending on the sparseType (varargin{1}). If Gn is a sparse matrix, 
%    each row represents a grid point, and the entries represent the 
%    weighted contribution of trajectory points to each grid point. The 
%    size is [Nu_tot, nPt], where Nu_tot is prod(N_u) and nPt the number of
%    trajectory points. Gn is the approximation of the inverse gridding. It
%    grids the trajectory to the grid.
%   Gu as varargout{1} or {2}: Gu is a normalized sparse matrix or a 
%    bmSparseMat, depending on the sparseType (varargin{1}). If Gu is a 
%    sparse matrix, each row represents a trajectory point, and the entries 
%    represent the weighted contribution of grid points to each trajectory 
%    point. The size is [nPt, Nu_tot], where Nu_tot is prod(N_u) and nPt 
%    the number of trajectory points. Gu is the forward mapping, which maps
%    the grid points to the trajectory points.
%   Gut as varargout{3}: Gut is a normalized sparse matrix or a 
%    bmSparseMat, depending on the sparseType (varargin{1}). Gut is the
%    transpose of Gu and is backward mapping.
%
% Examples:
%   Gn = bmTraj2SparseMat(t, ve, N_u, dK_u, 'bmSparseMat', 'gauss', 3, ...
%                         [0.61, 10]);
%   [Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u);
%   [Gn, Gu, Gut] = bmTraj2SparseMat(t, ve, N_u, dK_u); 


%% Intialize arguments
% Extract optional arguments
[sparseType, kernelType, nWin, kernelParam] = bmVarargin(varargin); 

% Recursively work if t and v are cell arrays
if iscell(t)
    % If only Gn has to be calculated
    if nargout == 1
        Gn  = cell(size(t));
        for i = 1:size(t(:), 1)
            Gn{i} = bmTraj2SparseMat(t{i}, v{i}, N_u, dK_u, sparseType, ...
                kernelType, nWin, kernelParam);
        end
        varargout{1} = Gn; 
        return;

    % If Gu and Gut has to be calculated
    elseif nargout == 2
        Gu  = cell(size(t));
        Gut = cell(size(t));
        for i = 1:size(t(:), 1)
            [Gu{i}, Gut{i}] = bmTraj2SparseMat(t{i}, v{i}, N_u, dK_u, ...
                sparseType, kernelType, nWin, kernelParam);
        end
        varargout{1} = Gu;
        varargout{2} = Gut;
        return;
    
    % If Gn, Gu and Gut has to be calculated
    elseif nargout == 3
        Gn  = cell(size(t));
        Gu  = cell(size(t));
        Gut = cell(size(t));
        for i = 1:size(t(:), 1)
            [Gn{i}, Gu{i}, Gut{i}] = bmTraj2SparseMat(t{i}, v{i}, N_u, ...
                dK_u, sparseType, kernelType, nWin, kernelParam);
        end
        varargout{1} = Gn;
        varargout{2} = Gu;
        varargout{3} = Gut;
        return;
    else
        error('wrong list of arguments. ');
    end
end

% Set default values for empty variables
[kernelType, nWin, kernelParam] = ...
    bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);
sparseType                      = bmVarargin_sparseType(sparseType);

% Uniformely define double as type
t           = double(bmPointReshape(t));
Dn          = double(v(:)');
N_u         = double(single(N_u(:)'));
dK_u        = double(single(dK_u(:)'));
nWin        = double(single(nWin(:)'));
kernelParam = double(single(kernelParam(:)'));

imDim       = double(size(t, 1));
nPt         = double(size(t, 2));

% Check that the types are sparse
if  not(strcmp(sparseType, 'bmSparseMat'))
    error('The given sparseType is not recognized');
end


%% Preparing Nu, t and Du
% dK_u and N_u define the grid on which the data is regridded. 
% Rescale the k-space grid to make it one in each direction.
% Dn is the volume elements


% Initialize variables
Nx_u = 0; 
Ny_u = 0;
Nz_u = 0;
Nu_tot = 1; % Total number of points
Du = 1; % Total distance in the new grid
if imDim > 0
    % Number of points in the first dimension of the new grid
    Nx_u = N_u(1, 1); 
    % Update total number of points
    Nu_tot = Nu_tot * Nx_u; 
    % Scale the first dimension of the trajectory to match the grid spacing
    t(1, :) = t(1, :)/dK_u(1, 1); 
    % Scale the volume elements accordingly
    Dn = Dn/dK_u(1, 1); 
    % Calculate the shift to center the trajectory
    myTrajShift = fix(Nx_u/2 + 1); 
    % Calculate the field of view in the first dimension
    FoVx_u = 1/dK_u(1, 1); 
    % Calculate the distance between grid points in the new grid
    dx_u = FoVx_u/Nx_u; 
    % Update the total distance
    Du = Du*dx_u; 
end
if imDim > 1 
    % See dim > 0 for comments
    Ny_u = N_u(1, 2);
    Nu_tot = Nu_tot*Ny_u;
    t(2, :) = t(2, :)/dK_u(1, 2);
    Dn = Dn/dK_u(1, 2);
    myTrajShift = [fix(Nx_u/2 + 1), fix(Ny_u/2 + 1)]';
    FoVy_u = 1/dK_u(1, 2);
    dy_u = FoVy_u/Ny_u;
    Du = Du*dy_u;
end
if imDim > 2
    % See dim > 0 for comments
    Nz_u = N_u(1, 3);
    Nu_tot = Nu_tot*Nz_u;
    t(3, :) = t(3, :)/dK_u(1, 3);
    Dn = Dn/dK_u(1, 3);
    myTrajShift = [fix(Nx_u/2 + 1), fix(Ny_u/2 + 1), fix(Nz_u/2 + 1)]';
    FoVz_u = 1/dK_u(1, 3);
    dz_u = FoVz_u/Nz_u;
    Du = Du*dz_u;
end

t = t + repmat(myTrajShift, [1, nPt]);


%% Deleting trajectory points that are out of the space
% Set mask true for point coordinates outside [1, Ni_u] interval for 
% i = x,y,z, so that only points inside are mapped to the grid
deleteMask = false(1, nPt);
if imDim > 0
    deleteMask = deleteMask | (t(1, :) < 1) | (t(1, :) > Nx_u);
end
if imDim > 1
    deleteMask = deleteMask | (t(2, :) < 1) | (t(2, :) > Ny_u);
end
if imDim > 2
    deleteMask = deleteMask | (t(3, :) < 1) | (t(3, :) > Nz_u);
end


%% Create full grid from window-width
% Differentiate between even and odd window-width. Calculate grid from 
% window-width
if mod(nWin, 2) == 0  % for even window-width
    if imDim == 1
        cx = ndgrid(-nWin/2-1:nWin/2);
        myFloorShift = 0;
    elseif imDim == 2
        [cx, cy] = ndgrid(-nWin/2-1:nWin/2, -nWin/2-1:nWin/2);
        myFloorShift = [0, 0]';
    elseif imDim == 3 % Create 3 dimensional full grid from window-width
        [cx, cy, cz] = ndgrid(-nWin/2-1:nWin/2, -nWin/2-1:nWin/2, ...
                              -nWin/2-1:nWin/2);
        myFloorShift = [0, 0, 0]';
    end
else % for odd window-width
    if imDim == 1
        cx = ndgrid(-fix(nWin/2):fix(nWin/2));
        myFloorShift = 0.5;
    elseif imDim == 2
        [cx, cy] = ndgrid(-fix(nWin/2):fix(nWin/2), ...
                          -fix(nWin/2):fix(nWin/2));
        myFloorShift = [0.5, 0.5]';
    elseif imDim == 3 % Create 3 dimensional full grid from window-width
        [cx, cy, cz] = ndgrid(-fix(nWin/2):fix(nWin/2), ...
                              -fix(nWin/2):fix(nWin/2), ...
                              -fix(nWin/2):fix(nWin/2));
        myFloorShift = [0.5, 0.5, 0.5]';
    end
end

% Turn cx, cy and cz into row vectors and concatenate them along dim 1
if imDim == 1
    c = cx(:)';
elseif imDim == 2
    c = [cx(:)'; cy(:)'];
elseif imDim == 3
    c = [cx(:)'; cy(:)'; cz(:)'];
end


%% Compute integer and remainder
% Repeat grid for every trajectory point
c = repmat(c, [1, 1, nPt]); 
nNb = double(size(c, 2));

% Add shift to trajectory (only important for odd window width) and
% seperate into integer and remainder
t_floor = floor(t + repmat(myFloorShift, [1, nPt])); 
t_rest  = t - t_floor; 

% Add 3rd dimension to copy integer of trajectory points to every point in 
% the window grid
t_floor = reshape(t_floor, [imDim, 1, nPt]); 
t_floor =  repmat(t_floor, [1, nNb, 1]);

% Repeat for the remainder
t_rest  = reshape(t_rest,  [imDim, 1, nPt]); 
t_rest  =  repmat(t_rest,  [1, nNb, 1]);


%% Compute kernel weights 
% Calculate the difference between points in the window grid (dim 2) to the
% remainder of the trajectory points
d = t_rest - c; 

% Calculate distance
temp_square = 0;
for i = 1:imDim
    temp_square = temp_square + d(i, :, :).^2; 
end
d = sqrt(temp_square); 

% Increase volume elements size to window grid x nPt, if not empty
if ~isempty(Dn) 
    Dn = reshape(Dn, [1, nPt]);
    Dn =  repmat(Dn, [nNb, 1]);
end

% The distance is used to compute the kernel weights, which determine the 
% influence of each trajectory point on the surrounding grid points.
if strcmp(kernelType, 'gauss')
    mySigma     = kernelParam(1);
    K_max       = kernelParam(2);

    % Calculate the Gaussian weight using the normal probability density 
    % function. The weights are higher for distances close to 0
    myWeight    = normpdf(d(:), 0, mySigma); 

elseif strcmp(kernelType, 'kaiser')
    myTau       = kernelParam(1);
    myAlpha     = kernelParam(2);
    K_max       = kernelParam(3); 

    % Compute modified Bessel function for nomalization
    I0myAlpha   = besseli(0, myAlpha); 
    
    % Base weight on distance from grid with quadratic decay and clipped 
    % between 0 and inf and add nonlinearity
    myWeight    = max(1-(d/myTau).^2, 0); 
    myWeight    = myAlpha*sqrt(myWeight);

    % Compute modified Bessel function of the weight and normalize
    myWeight    = besseli(0, myWeight)/I0myAlpha; 
end

% Reshape weights to be of size [window grid, trajectory points]
myWeight = reshape(myWeight, [nNb, nPt]); 


%% Compute grid indices for correct placement
% n represents the indices of the points in the grid that are closest to 
% each point in the trajectory
n = t_floor + c; 

% Free up space (could use clear)
d = 0; 
t_floor = 0;
t_rest = 0;

if imDim == 1
    % Adjust the indices of the points to fit within the grid dimensions 
    % (ensure they wrap around correctly if out of bounds)
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1; 

    % Calculate the linear indices
    n = 1 + (n(1, :, :) - 1);

elseif imDim == 2 % See imDim == 1 for comments
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1;
    n(2, :, :) = mod(n(2, :, :)-1, Ny_u)+1;
    n = 1 + (n(1, :, :) - 1) + (n(2, :, :) - 1)*Nx_u;

elseif imDim == 3 % See imDim == 1 for comments
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1; 
    n(2, :, :) = mod(n(2, :, :)-1, Ny_u)+1;
    n(3, :, :) = mod(n(3, :, :)-1, Nz_u)+1;
    n = 1 + (n(1, :, :) - 1) + (n(2, :, :) - 1)*Nx_u + ...
        (n(3, :, :) - 1)*Nx_u*Ny_u; 
end

% Remove invalid points
n(:, :, deleteMask) = []; 
myWeight(:, deleteMask) = [];
myOne = ones(1, nPt);
myOne(1, deleteMask) = 0;
if ~isempty(Dn)
    Dn(:, deleteMask) = [];
end

% Prepare indicies for sparse matrix
ind_1 = double(n(:));
ind_2 = double(bmSparseMat_r_nJump2index(nNb*myOne)');

% Convert to column vector
myWeight = double(myWeight(:));
Dn = double(Dn(:));


%% Compute Gn, Gu and Gut

Gn  = []; 
Gu  = []; 
Gut = []; 

if (nargout == 1) || (nargout == 3) % computing Gn
    % Create transposed sparse matrix for weights * volume elements and 
    % increase the matrix to match the  size [Nu_tot, nPt], by adding all 
    % zero sparse matrices
    mySparse  = sparse(ind_2, ind_1, myWeight.*Dn)'; 
    mySparse  = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);
    
    % Sum of weights of all trajectory points for every grid point and
    % extract all non-zero entries (sum over rows)
    mySum = sum(mySparse, 2); 
    [mySum_ind_1, ~, mySum] = find(mySum);

    % Create diagonal sparse matrix from the sum and ensure correct size
    myDiag = sparse(mySum_ind_1, mySum_ind_1, 1./mySum); 
    myDiag = bmSparseMat_completeMatlabSparse(myDiag, [Nu_tot, Nu_tot]);
    
    % Normalize each row and ensure correct size
    mySparse = myDiag*mySparse; 
    mySparse = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);
    
    if strcmp(sparseType, 'bmSparseMat')
        % Create bmSparseMat object from sparse matrix to output Gn
        Gn = bmSparseMat_matlabSparse2bmSparseMat(mySparse, N_u, dK_u, ...
                                                  kernelType, nWin, ...
                                                  kernelParam); 
        
        % Remove bins where r_nJump is zero
        Gn.l_squeeze; 

        % Turn difference between indices of r_ind into r_jump, prepare Gn
        Gn.cpp_prepare('one_block', [], []); 

    else
        % Output sparse matrix if not bmSparseMat
        Gn = mySparse; 
    end
end

% Free up space (could use clear)
mySparse = 0;
mySum = 0;
myDiag = 0;

if (nargout == 2) || (nargout == 3) % computing Gu and Gut
    % Create sparse matrix for weights * product of distance between grid 
    % and increase the matrix to match the size [nPt, Nu_tot], by adding 
    % all zero sparse matrices
    mySparse  = sparse(ind_2, ind_1, myWeight*Du); 
    mySparse  = bmSparseMat_completeMatlabSparse(mySparse, [nPt, Nu_tot]);

    % Sum of weights of all grid points for every trajectory point and
    % extract all non-zero entries (sum over rows)
    mySum = sum(mySparse, 2);
    [mySum_ind_1, ~, mySum] = find(mySum);
    
    % Create diagonal sparse matrix from the sum and ensure correct size
    myDiag   = sparse(mySum_ind_1, mySum_ind_1, 1./mySum);
    myDiag   = bmSparseMat_completeMatlabSparse(myDiag,   [nPt, nPt]);
    
    % Normalize each row and ensure correct size
    mySparse = myDiag*mySparse;
    mySparse = bmSparseMat_completeMatlabSparse(mySparse, [nPt, Nu_tot]);
    
    
    if strcmp(sparseType, 'bmSparseMat')
        % Create bmSparseMat object from sparse matrix
        Gu  = bmSparseMat_matlabSparse2bmSparseMat(mySparse,  N_u, ...
                                                   dK_u, kernelType, ...
                                                   nWin, kernelParam);

        % Create transpose bmSparseMat object
        Gut = bmSparseMat_matlabSparse2bmSparseMat(mySparse', N_u, ...
                                                   dK_u, kernelType, ...
                                                   nWin, kernelParam); 
        
        % Prepare Gu and Gut
        Gu.cpp_prepare('one_block', [], []); 
        Gut.l_squeeze;
        Gut.cpp_prepare('one_block', [], []);

    else
        % Output sparse matrix and transpose if not bmSparseMat
        Gu = mySparse; 
        Gut = mySparse';
    end
end

% Free up space (could use clear)
mySparse = 0;
mySum = 0;
myDiag = 0;

% Return variables required
if nargout == 1
    varargout{1} = Gn; 
elseif nargout == 2
    varargout{1} = Gu;
    varargout{2} = Gut;
elseif nargout == 3
    varargout{1} = Gn;
    varargout{2} = Gu;
    varargout{3} = Gut;
end

end % END_function


