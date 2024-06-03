% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% I thank 
%
% Gabriele Bonanno
%
% for the help he brought about gridders at the 
% early stage of developpment of the 
% reconstruciton code. 


function data_u = bmGridder_n2u(data_n, t, Dn, N_u, dK_u, varargin)

% argin initial -----------------------------------------------------------

[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam); 

t           = double(bmPointReshape(t)); 
data_n      = single(bmPointReshape(data_n)); 
Dn          = double(bmPointReshape(Dn)); 

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


% deleting trajectory points that are out of the spat ---------------------
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
% END_deleting trajectory points that are out of the spat -----------------





% we make a cas differentiation between even and odd window-width.
if mod(nWin, 2) == 0  % for even window-width
    if imDim == 1
        cx = ndgrid(-nWin/2-1:nWin/2);
        myFloorShift = 0;
    elseif imDim == 2
        [cx, cy] = ndgrid(-nWin/2-1:nWin/2, -nWin/2-1:nWin/2);
        myFloorShift = [0, 0]';
    elseif imDim == 3
        [cx, cy, cz] = ndgrid(-nWin/2-1:nWin/2, -nWin/2-1:nWin/2, -nWin/2-1:nWin/2);
        myFloorShift = [0, 0, 0]';
    end
else % for odd window-width
    if imDim == 1
        cx = ndgrid(-fix(nWin/2):fix(nWin/2));
        myFloorShift = 0.5;
    elseif imDim == 2
        [cx, cy] = ndgrid(-fix(nWin/2):fix(nWin/2), -fix(nWin/2):fix(nWin/2));
        myFloorShift = [0.5, 0.5]';
    elseif imDim == 3
        [cx, cy, cz] = ndgrid(-fix(nWin/2):fix(nWin/2), -fix(nWin/2):fix(nWin/2), -fix(nWin/2):fix(nWin/2));
        myFloorShift = [0.5, 0.5, 0.5]';
    end
end

if imDim == 1
    c = cx(:)';
elseif imDim == 2
    c = [cx(:)'; cy(:)'];
elseif imDim == 3
    c = [cx(:)'; cy(:)'; cz(:)'];
end

c = repmat(c, [1, 1, nPt]); 
nNb = double(size(c, 2)); 

t_floor = floor(t + repmat(myFloorShift, [1, nPt]));
t_rest  = t - t_floor; 

t_floor = reshape(t_floor, [imDim, 1, nPt]);
t_floor =  repmat(t_floor, [1, nNb, 1]); 

t_rest  = reshape(t_rest,  [imDim, 1, nPt]); 
t_rest  =  repmat(t_rest,  [1, nNb, 1]); 


d = t_rest - c; 
temp_square = 0; 
for i = 1:imDim
    temp_square = temp_square + d(i, :, :).^2; 
end
d = sqrt(temp_square); 

Dn = reshape(Dn, [1, nPt]); 
Dn =  repmat(Dn, [nNb, 1]);

if strcmp(kernelType, 'gauss')
    mySigma     = kernelParam(1);
    K_max       = kernelParam(2); 
    myWeight    = normpdf(d(:), 0, mySigma);
elseif strcmp(kernelType, 'kaiser')
    myTau       = kernelParam(1);
    myAlpha     = kernelParam(2);
    K_max       = kernelParam(3); 
    I0myAlpha   = besseli(0, myAlpha);
    
    myWeight    = max(1-(d/myTau).^2, 0);
    myWeight    = myAlpha*sqrt(myWeight);
    myWeight    = besseli(0, myWeight)/I0myAlpha;
end
myWeight = myWeight(:).*Dn(:); 
myWeight = reshape(myWeight, [nNb, nPt]); 

n = t_floor + c; 

if imDim == 1
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1;
    n = 1 + (n(1, :, :) - 1);
elseif imDim == 2
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1;
    n(2, :, :) = mod(n(2, :, :)-1, Ny_u)+1;
    n = 1 + (n(1, :, :) - 1) + (n(2, :, :) - 1)*Nx_u;
elseif imDim == 3
    n(1, :, :) = mod(n(1, :, :)-1, Nx_u)+1;
    n(2, :, :) = mod(n(2, :, :)-1, Ny_u)+1;
    n(3, :, :) = mod(n(3, :, :)-1, Nz_u)+1;
    n = 1 + (n(1, :, :) - 1) + (n(2, :, :) - 1)*Nx_u + (n(3, :, :) - 1)*Nx_u*Ny_u;
end
n = n(:);

nJump = cat(1, 0, n); 
nJump = nJump(2:end) - nJump(1:end-1); 
nJump(1) = n(1) - 1; 

n = 0; 
d = 0; 
t_floor = 0; 
t_rest = 0; 


% bmGridder3_n2u_mex ------------------------------------------------------
data_n_real = single(real(data_n)); 
data_n_imag = single(imag(data_n)); 
myWeight    = single(myWeight); 

nJump    = int32(nJump);
nCh      = int32(nCh); 
nNb      = int32(nNb); 
nPt      = int32(nPt); 
Nu_tot   = int32(Nu_tot); 

[data_u_real, data_u_imag] = bmGridder_n2u_mex(data_n_real, data_n_imag, myWeight, nJump, nCh, nNb, nPt, Nu_tot); 
% END_bmGridder3_n2u_mex --------------------------------------------------




% reshaping ---------------------------------------------------------------
data_u = data_u_real + 1i*data_u_imag; 
data_u = reshape(data_u, [nCh, N_u]);
% END_reshaping -----------------------------------------------------------



end % END_function


