% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% t is the arbitrary_grid. It can be cartesian or non-cartesian.
%
% The possible values of 'gridding_type' are 'G' or 'G_inv'.
%
% Remember that the choice of multiplying by the matrix or its transpose
% is done at multiplication time. But the gridding matrix given as input
% argument is the same for the direct matrix multiplication and the
% transpose matrix multiplication.
%
% varargin{1} is nWin. Default value is 3.
% varargin{2} is kernelParam. Default is [0.61, 10]. We use Gaussian
% gridding kernel.
%
% The pillar_gridd is implicitely given by N_u and d_u. It is assumed that
% the upper_left_corner of the pillar_gridd is located in
%
%           -d_u.*N_u/2 = [-dx*N_x/2 , -dy*N_y/2 , -dz*N_z/2]
%
% After rescaling by d_u, we shift then t by N_u/2 + 1 so that
% the pillar_gridd has upper_left_corner in [1, 1, 1]. All along, it is of
% course assumed that all components of N_u are even numbers.
%
%

function griddingMatrix = bmGriddingMatrix_prepare(t, N_u, d_u, nCh, gridding_type, varargin)

% argin initial -----------------------------------------------------------
[nWin, kernelParam] = bmVarargin(varargin);

if isempty(nWin)
    nWin = 3;
end
if isempty(kernelParam)
    kernelParam = [0.61, 10];
end

t           = double(bmPointReshape(t));
nCh         = double(nCh);
nPt         = double(size(t, 2));
N_u         = double(N_u(:)');
imDim       = double(size(N_u(:), 1));
d_u         = double(d_u(:)');
nWin        = double(nWin);
% END_argin initial -------------------------------------------------------






% preparing Nu and t ------------------------------------------------------
Nx_u = 0;
Ny_u = 0;
Nz_u = 0;
if imDim > 0
    Nx_u = N_u(1, 1);
    t(1, :) = t(1, :)/d_u(1, 1);
    myTrajShift = fix(Nx_u/2 + 1);
end
if imDim > 1
    Ny_u = N_u(1, 2);
    t(2, :) = t(2, :)/d_u(1, 2);
    myTrajShift = [fix(Nx_u/2 + 1), fix(Ny_u/2 + 1)]';
end
if imDim > 2
    Nz_u = N_u(1, 3);
    t(3, :) = t(3, :)/d_u(1, 3);
    myTrajShift = [fix(Nx_u/2 + 1), fix(Ny_u/2 + 1), fix(Nz_u/2 + 1)]';
end

t = t + repmat(myTrajShift, [1, nPt]);
% END_preparing Nu and t --------------------------------------------------


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
nPt = size(t, 2);
% END_deleting trajectory points that are out of the box ------------------





tx              = [];
ty              = [];
tz              = [];
if imDim == 1
    tx          = single(t(1, :));
    Nx          = int32(N_u(1, 1));
elseif imDim == 2
    tx          = single(t(1, :));
    ty          = single(t(2, :));
    Nx          = int32(N_u(1, 1));
    Ny          = int32(N_u(1, 2));
elseif imDim == 3
    tx          = single(t(1, :));
    ty          = single(t(2, :));
    tz          = single(t(3, :));
    Nx          = int32(N_u(1, 1));
    Ny          = int32(N_u(1, 2));
    Nz          = int32(N_u(1, 3));
end

nCh             = int32(nCh);
nPt             = int32(nPt);

nWin            = int32(nWin);
kernelParam_1   = single(kernelParam(1, 1));
kernelParam_2   = single(kernelParam(1, 2));


if imDim == 1
    
    secret_length   = bmGriddingMatrix_secret_length1_mex(tx, nCh, nPt, Nx, nWin);
    
    if strcmp(gridding_type, 'G')
        [w, u_ind]      = bmGriddingMatrix_prepare_G1_mex(      tx, Dn, ...
                                                                nCh, nPt, Nx, ...
                                                                nWin, kernelParam_1, kernelParam_2, ...
                                                                secret_length);
    elseif strcmp(gridding_type, 'G_inv')
        [w, u_ind]      = bmGriddingMatrix_prepare_G_inv1_mex(  tx, Dn, ...
                                                                nCh, nPt, Nx, ...
                                                                nWin, kernelParam_1, kernelParam_2, ...
                                                                secret_length);
    end
    
elseif imDim == 2
    
    secret_length   = bmGriddingMatrix_secret_length2_mex(tx, ty, tz, nPt, Nx, Ny, nWin);
    
    if strcmp(gridding_type, 'G')
        [w, u_ind]      = bmGriddingMatrix_prepare_G2_mex(      tx, ty, Dn, ...
                                                                nCh, nPt, Nx, Ny, ...
                                                                nWin, kernelParam_1, kernelParam_2, ...
                                                                secret_length);
    elseif strcmp(gridding_type, 'G_inv')
        [w, u_ind]      = bmGriddingMatrix_prepare_G_inv2_mex(  tx, ty, Dn, ...
                                                                nCh, nPt, Nx, Ny, ...
                                                                nWin, kernelParam_1, kernelParam_2, ...
                                                                secret_length);
    end
    
elseif imDim == 3
    
    secret_length   = bmGriddingMatrix_secret_length3_mex(tx, ty, tz, nCh, nPt, Nx, Ny, Nz, nWin);
    
    if strcmp(gridding_type, 'G')
        [w, u_ind]      = bmGriddingMatrix_prepare_G3_mex(      tx, ty, tz, Dn, ...
                                                                nCh, nPt, Nx, Ny, Nz, ...
                                                                nWin, kernelParam_1, kernelParam_2, ...
                                                                secret_length);
    elseif strcmp(gridding_type, 'G_inv')
        
        [w, u_ind]      = bmGriddingMatrix_prepare_G_inv3_mex(  tx, ty, tz, Dn, ...
                                                                nCh, nPt, Nx, Ny, Nz, ...
                                                                nWin, kernelParam_1, kernelParam_2, ...
                                                                secret_length);
    end
end

griddingMatrix = bmGriddingMatrix(  w, u_ind, ...
                                    nCh, nPt, Nx, Ny, Nz, secret_length, ...
                                    gridding_type);

end % END_function


