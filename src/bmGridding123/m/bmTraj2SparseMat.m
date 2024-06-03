% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% v is the volumeElement list. 
%
% varargin : [sparseType, kernelType, nWin, kernelParam]



function varargout = bmTraj2SparseMat(t, v, N_u, dK_u, varargin)

% argin initial -----------------------------------------------------------

[sparseType, kernelType, nWin, kernelParam] = bmVarargin(varargin);

if iscell(t)
    if nargout == 1
        Gn  = cell(size(t));
        for i = 1:size(t(:), 1)
            Gn{i} = bmTraj2SparseMat(t{i}, v{i}, N_u, dK_u, sparseType, kernelType, nWin, kernelParam);
        end
        varargout{1} = Gn; 
        return;
        
    elseif nargout == 2
        Gu  = cell(size(t));
        Gut = cell(size(t));
        for i = 1:size(t(:), 1)
            [Gu{i}, Gut{i}] = bmTraj2SparseMat(t{i}, v{i}, N_u, dK_u, sparseType, kernelType, nWin, kernelParam);
        end
        varargout{1} = Gu;
        varargout{2} = Gut;
        return;
        
    elseif nargout == 3
        Gn  = cell(size(t));
        Gu  = cell(size(t));
        Gut = cell(size(t));
        for i = 1:size(t(:), 1)
            [Gn{i}, Gu{i}, Gut{i}] = bmTraj2SparseMat(t{i}, v{i}, N_u, dK_u, sparseType, kernelType, nWin, kernelParam);
        end
        varargout{1} = Gn;
        varargout{2} = Gu;
        varargout{3} = Gut;
        return;
    else
        error('wrong list of arguments. ');
        return;
    end
end

[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);
sparseType                      = bmVarargin_sparseType(sparseType);


t           = double(bmPointReshape(t));
Dn          = double(v(:)');
N_u         = double(single(N_u(:)'));
dK_u        = double(single(dK_u(:)'));
nWin        = double(single(nWin(:)'));
kernelParam = double(single(kernelParam(:)'));

imDim       = double(size(t, 1));
nPt         = double(size(t, 2));

if  not(strcmp(sparseType, 'bmSparseMat')) && not(strcmp(sparseType, 'matlabSparseMat'))
    error('The given sparseType is not recognized');
    return;
end
% END_argin initial -------------------------------------------------------


% preparing Nu and t and Du -----------------------------------------------
Nx_u = 0;
Ny_u = 0;
Nz_u = 0;
Nu_tot = 1;
Du = 1;
if imDim > 0
    Nx_u = N_u(1, 1);
    Nu_tot = Nu_tot*Nx_u;
    t(1, :) = t(1, :)/dK_u(1, 1);
    Dn = Dn/dK_u(1, 1);
    myTrajShift = fix(Nx_u/2 + 1);
    FoVx_u = 1/dK_u(1, 1);
    dx_u = FoVx_u/Nx_u;
    Du = Du*dx_u;
end
if imDim > 1
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
% END_preparing Nu and t and Du -------------------------------------------


% deleting trajectory points that are out of the spat ---------------------
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

if ~isempty(Dn)
    Dn = reshape(Dn, [1, nPt]);
    Dn =  repmat(Dn, [nNb, 1]);
end

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
myWeight = reshape(myWeight, [nNb, nPt]);

n = t_floor + c;

d = 0;
t_floor = 0;
t_rest = 0;

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
n(:, :, deleteMask) = [];
myWeight(:, deleteMask) = [];
myOne = ones(1, nPt);
myOne(1, deleteMask) = 0;
if ~isempty(Dn)
    Dn(:, deleteMask) = [];
end

ind_1 = double(n(:));
ind_2 = double(bmSparseMat_r_nJump2index(nNb*myOne)');
myWeight = double(myWeight(:));
Dn = double(Dn(:));


Gn  = []; 
Gu  = []; 
Gut = []; 


if (nargout == 1) || (nargout == 3) % computing Gn
    mySparse  = sparse(ind_2, ind_1, myWeight.*Dn)';
    mySparse  = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);
    
    mySum = sum(mySparse, 2);
    [mySum_ind_1, ~, mySum] = find(mySum);
    myDiag = sparse(mySum_ind_1, mySum_ind_1, 1./mySum);
    myDiag = bmSparseMat_completeMatlabSparse(myDiag, [Nu_tot, Nu_tot]);
    
    mySparse = myDiag*mySparse;
    mySparse = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);
    
    if strcmp(sparseType, 'bmSparseMat')
        Gn = bmSparseMat_matlabSparse2bmSparseMat(mySparse, N_u, dK_u, kernelType, nWin, kernelParam);
        
        Gn.l_squeeze; 
        Gn.cpp_prepare('one_block', [], []); 
    else
        Gn = mySparse;
    end
end

mySparse = 0;
mySum = 0;
myDiag = 0;

if (nargout == 2) || (nargout == 3) % computing Gu and Gut
    mySparse  = sparse(ind_2, ind_1, myWeight*Du);
    mySparse  = bmSparseMat_completeMatlabSparse(mySparse, [nPt, Nu_tot]);
    
    mySum = sum(mySparse, 2);
    [mySum_ind_1, ~, mySum] = find(mySum);
    myDiag   = sparse(mySum_ind_1, mySum_ind_1, 1./mySum);
    myDiag   = bmSparseMat_completeMatlabSparse(myDiag,   [nPt, nPt]);
    
    mySparse = myDiag*mySparse;
    mySparse = bmSparseMat_completeMatlabSparse(mySparse, [nPt, Nu_tot]);
    
    
    if strcmp(sparseType, 'bmSparseMat')
        Gu  = bmSparseMat_matlabSparse2bmSparseMat(mySparse,  N_u, dK_u, kernelType, nWin, kernelParam);
        Gut = bmSparseMat_matlabSparse2bmSparseMat(mySparse', N_u, dK_u, kernelType, nWin, kernelParam);
        
        Gu.cpp_prepare('one_block', [], []); 
        Gut.l_squeeze; 
        Gut.cpp_prepare('one_block', [], []); 
        

    else
        Gu = mySparse;
        Gut = mySparse';
    end
end

mySparse = 0;
mySum = 0;
myDiag = 0;

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


