function data_u = bmGridder_n2u_leight(y, t, v, N_u, dK_u, varargin)
% data_u = bmGridder_n2u_leight(y, t, v, N_u, dK_u, varargin)
%
% Grids non-Cartesian data onto a Cartesian grid. This function is used 
% specifically for non-iterative reconstruction methods where the gridding 
% is computed only once. In the case of iterative methods, a sparse 
% gridding matrix is first computed, and then applied via matrix multiplication. 
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributor:
%   Mauro Leidi (Documentation)
%   HES-SO
%   Lausanne - Switzerland
%   May 2025
%
% Acknowledgments:
%   Special thanks to Gabriele Bonanno for his help on gridders at the 
%   early stage of development of the reconstruction code.
%
% Parameters:
%   y (array): The raw data y, acquired along the non-Cartesian trajectory
%   t (array): The sampling trajectory coordinates
%   v (array): The volume elements associated with the non-Cartesian sampling
%   N_u (vector): The size of the Cartesian grid
%   dK_u (scalar or vector): The step size of the Cartesian grid
%   varargin: Optional arguments
%
% Returns:
%   data_u (array): The gridded data on the Cartesian grid
% argin initial -----------------------------------------------------------

[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[~, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam); 

t           = single(bmPointReshape(t)); 
y      = single(bmPointReshape(y)); 
v          = single(bmPointReshape(v)); % These are the volume elements

nCh         = double(size(y, 1)); % Amount of coils for the acquisition
nPt         = double(size(y, 2)); % Total amount of sampling points
imDim       = double(size(t, 1)); % 2 if 2D, 3 if 3D image
N_u         = double(N_u(:)'); 
dK_u        = double(dK_u(:)'); 
nWin        = double(nWin(:)'); 
kernelParam = double(kernelParam(:)'); 

% END_argin initial -------------------------------------------------------




% preparing Nu and t ------------------------------------------------------
% This step is a rescaling step that is needed to transform the trajectory 
% into a new convention where we can work with indexes. In this new
% convention the cartesian matrix has integer steps of 1 (dk_x,y,z = 1) and
% the smallest coordinate is at 1,1. To do so we divide each codinate by
% the correct dk_ and after that shift all points by N_/2 + 1. This allows
% to take the integer part of the trajectory points to find it's neighboor
% on the cartesian grid.
Nx_u = 0; 
Ny_u = 0; 
Nz_u = 0; 
Nu_tot = 1; 
if imDim > 0
    Nx_u = N_u(1, 1);
    Nu_tot = Nu_tot*Nx_u; 
    t(1, :) = t(1, :)/dK_u(1, 1);
    v = v/dK_u(1, 1); 
    myTrajShift = fix(Nx_u/2 + 1);  
end
if imDim > 1 % This is the last case for 2D 
    Ny_u = N_u(1, 2);
    Nu_tot = Nu_tot*Ny_u; 
    t(2, :) = t(2, :)/dK_u(1, 2);
    v = v/dK_u(1, 2); 
    myTrajShift = [fix(Nx_u/2 + 1), fix(Ny_u/2 + 1)]';  
end
if imDim > 2 % This is the last case for 3D 
    Nz_u = N_u(1, 3);
    Nu_tot = Nu_tot*Nz_u; 
    t(3, :) = t(3, :)/dK_u(1, 3);
    v = v/dK_u(1, 3); 
    myTrajShift = [fix(Nx_u/2 + 1), fix(Ny_u/2 + 1), fix(Nz_u/2 + 1)]';  
end


t = t + repmat(myTrajShift, [1, nPt]);
% END_preparing Nu and t --------------------------------------------------
% Now the trajecory and the cartesian grid are rescaled and shifted. If
% some points are out of the grid we will filter them out in the following 
% step.

% deleting trajectory points that are out of the box ----------------------
temp_mask = false(1, nPt); 
if imDim > 0
    temp_mask = temp_mask | (t(1, :) < 1) | (t(1, :) > Nx_u);  
end
if imDim > 1
    temp_mask = temp_mask | (t(2, :) < 1) | (t(2, :) > Ny_u);  
end
if imDim > 2
    temp_mask = temp_mask | (t(3, :) < 1) | (t(3, :) > Nz_u);  
end

t(:, temp_mask)         = [];
y(:, temp_mask)    = []; 
v(:, temp_mask)        = []; 
nPt = size(t, 2); 
% END_deleting trajectory points that are out of the box ------------------




% bmGridder3_n2u_mex ------------------------------------------------------
y_real = single(real(y)); 
y_imag = single(imag(y)); 

tx = []; 
ty = [];
tz = [];
if imDim == 1
    tx  = single(t(1, :));
    Nx  = int32(N_u(1, 1)); 
elseif imDim == 2
    tx  = single(t(1, :));
    ty  = single(t(2, :));
    Nx  = int32(N_u(1, 1));
    Ny  = int32(N_u(1, 2));
elseif imDim == 3
    tx  = single(t(1, :));
    ty  = single(t(2, :));
    tz  = single(t(3, :));
    Nx  = int32(N_u(1, 1));
    Ny  = int32(N_u(1, 2));
    Nz  = int32(N_u(1, 3));
end

v       = single(v); 

nCh      = int32(nCh); 
nPt      = int32(nPt); 

nWin            = int32(nWin); 
kernelParam_1   = single(kernelParam(1, 1));
kernelParam_2   = single(kernelParam(1, 2));

if imDim == 1
    [data_u_real, data_u_imag] = bmGridder_n2u_leight1_mex(y_real, y_imag, tx,            v, nCh, nPt, Nx,           nWin, kernelParam_1, kernelParam_2); 
elseif imDim == 2
    [data_u_real, data_u_imag] = bmGridder_n2u_leight2_mex(y_real, y_imag, tx, ty,        v, nCh, nPt, Nx, Ny,       nWin, kernelParam_1, kernelParam_2); 
elseif imDim == 3
    [data_u_real, data_u_imag] = bmGridder_n2u_leight3_mex(y_real, y_imag, tx, ty, tz,    v, nCh, nPt, Nx, Ny, Nz,   nWin, kernelParam_1, kernelParam_2); 
end
% END_bmGridder3_n2u_mex --------------------------------------------------


% reshaping ---------------------------------------------------------------
data_u = data_u_real + 1i*data_u_imag; 
data_u = reshape(data_u, [nCh, N_u]);
% END_reshaping -----------------------------------------------------------


end % END_function


