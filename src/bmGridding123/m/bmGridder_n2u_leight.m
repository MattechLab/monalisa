% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023
%
% I thank 
%
% Gabriele Bonanno
%
% for the help he brought about gridders at the 
% early stage of developpment of the 
% reconstruciton code. 


function data_u = bmGridder_n2u_leight(data_n, t, Dn, N_u, dK_u, varargin)

% argin initial -----------------------------------------------------------

[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam); 

t           = single(bmPointReshape(t)); 
data_n      = single(bmPointReshape(data_n)); 
Dn          = single(bmPointReshape(Dn)); 

nCh         = double(size(data_n, 1)); 
nPt         = double(size(data_n, 2));
imDim       = double(size(t, 1)); 
N_u         = double(N_u(:)'); 
dK_u        = double(dK_u(:)'); 
nWin        = double(nWin(:)'); 
kernelParam = double(kernelParam(:)'); 

% END_argin initial -------------------------------------------------------




% preparing Nu and t ------------------------------------------------------
Nx_u = 0; 
Ny_u = 0; 
Nz_u = 0; 
Nu_tot = 1; 
if imDim > 0
    Nx_u = N_u(1, 1);
    Nu_tot = Nu_tot*Nx_u; 
    t(1, :) = t(1, :)/dK_u(1, 1);
    Dn = Dn/dK_u(1, 1); 
    myTrajShift = fix(Nx_u/2 + 1);  
end
if imDim > 1
    Ny_u = N_u(1, 2);
    Nu_tot = Nu_tot*Ny_u; 
    t(2, :) = t(2, :)/dK_u(1, 2);
    Dn = Dn/dK_u(1, 2); 
    myTrajShift = [fix(Nx_u/2 + 1), fix(Ny_u/2 + 1)]';  
end
if imDim > 2
    Nz_u = N_u(1, 3);
    Nu_tot = Nu_tot*Nz_u; 
    t(3, :) = t(3, :)/dK_u(1, 3);
    Dn = Dn/dK_u(1, 3); 
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
data_n(:, temp_mask)    = []; 
Dn(:, temp_mask)        = []; 
nPt = size(t, 2); 
% END_deleting trajectory points that are out of the box ------------------




% bmGridder3_n2u_mex ------------------------------------------------------
data_n_real = single(real(data_n)); 
data_n_imag = single(imag(data_n)); 

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

Dn       = single(Dn); 

nCh      = int32(nCh); 
nPt      = int32(nPt); 

nWin            = int32(nWin); 
kernelParam_1   = single(kernelParam(1, 1));
kernelParam_2   = single(kernelParam(1, 2));

if imDim == 1
    [data_u_real, data_u_imag] = bmGridder_n2u_leight1_mex(data_n_real, data_n_imag, tx,            Dn, nCh, nPt, Nx,           nWin, kernelParam_1, kernelParam_2); 
elseif imDim == 2
    [data_u_real, data_u_imag] = bmGridder_n2u_leight2_mex(data_n_real, data_n_imag, tx, ty,        Dn, nCh, nPt, Nx, Ny,       nWin, kernelParam_1, kernelParam_2); 
elseif imDim == 3
    [data_u_real, data_u_imag] = bmGridder_n2u_leight3_mex(data_n_real, data_n_imag, tx, ty, tz,    Dn, nCh, nPt, Nx, Ny, Nz,   nWin, kernelParam_1, kernelParam_2); 
end
% END_bmGridder3_n2u_mex --------------------------------------------------


% reshaping ---------------------------------------------------------------
data_u = data_u_real + 1i*data_u_imag; 
data_u = reshape(data_u, [nCh, N_u]);
% END_reshaping -----------------------------------------------------------


end % END_function


