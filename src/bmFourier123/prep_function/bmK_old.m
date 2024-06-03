% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function K = bmK(N_u, dK_u, nCh, varargin)

% argin_initial -----------------------------------------------------------
[kernelType, nWin, kernelParam] = bmVarargin(varargin); 
[kernelType, nWin, kernelParam] = bmVarargin_kernelType_nWin_kernelParam(kernelType, nWin, kernelParam);  


N_u         = double(single(N_u(:)')); 
dK_u        = double(single(dK_u(:)')); 
nWin        = double(single(nWin(:)')); 
kernelParam = double(single(kernelParam(:)')); 
K           = zeros(1, prod(N_u(:)), 'double'); 
imDim       = double(size(N_u(:), 1));
nCh         = double(single(nCh)); 

if sum(mod(N_u(:), 2)) > 0
   error('N_u must have all components even for the Fourier transform. ');
   return; 
end
% END_argin_initial -------------------------------------------------------


myTrajPoint = (fix(N_u/2) + 1)'; 
myWin       = -fix(nWin/2):fix(nWin/2); 
if imDim == 1
    cx = ndgrid(myWin);
    c = cx(:)';
    n = c + repmat(myTrajPoint ,[1, size(c, 2)]);
    nMask = (n(1, :) < 1) | (n(1, :) > N_u(1, 1)); 
elseif imDim == 2
    [cx, cy] = ndgrid(myWin, myWin);
    c = [cx(:)'; cy(:)'];
    n = c + repmat(myTrajPoint ,[1, size(c, 2)]);
    nMask = (n(1, :) < 1) | (n(2, :) < 1) | (n(1, :) > N_u(1, 1)) | (n(2, :) > N_u(1, 2)); 
elseif imDim == 3
    [cx, cy, cz] = ndgrid(myWin, myWin, myWin);
    c = [cx(:)'; cy(:)'; cz(:)'];
    n = c + repmat(myTrajPoint ,[1, size(c, 2)]);
    nMask = (n(1, :) < 1) | (n(2, :) < 1) | (n(3, :) < 1) | (n(1, :) > N_u(1, 1)) | (n(2, :) > N_u(1, 2)) | (n(3, :) > N_u(1, 3));
end
n = n(:, not(nMask));
myDiff = repmat(myTrajPoint, [1, size(n, 2)]) - n;


d = zeros(1, size(myDiff, 2));
for i = 1:imDim
    d = d + myDiff(i, :).^2;
end
d = sqrt(d);

if strcmp(kernelType, 'gauss')
    myWeight = normpdf(d(:), 0, kernelParam);
elseif strcmp(kernelType, 'kaiser')
    tau     = kernelParam(1);
    alpha   = kernelParam(2);
    I0alpha = besseli(0, alpha);
    
    myWeight = max(1-(d/tau).^2, 0);
    myWeight = alpha*sqrt(myWeight);
    myWeight = besseli(0, myWeight)/I0alpha;
end

if imDim == 1
    myIndexList = 1 + (n(1, :) - 1);
elseif imDim == 2
    myIndexList = 1 + (n(1, :) - 1) + (n(2, :) - 1)*N_u(1, 1);
elseif imDim == 3
    myIndexList = 1 + (n(1, :) - 1) + (n(2, :) - 1)*N_u(1, 1) + (n(3, :) - 1)*N_u(1, 1)*N_u(1, 2);
end
K(1, myIndexList) = myWeight;



K = reshape(K, [N_u, 1]);
if imDim > 0
    K = fftshift(ifft(ifftshift(K, 1), [], 1), 1)*N_u(1, 1)*dK_u(1, 1);
end
if imDim > 1
    K = fftshift(ifft(ifftshift(K, 2), [], 2), 2)*N_u(1, 2)*dK_u(1, 2);
end
if imDim > 2
    K = fftshift(ifft(ifftshift(K, 3), [], 3), 3)*N_u(1, 3)*dK_u(1, 3);
end
K = real(K); 
K = (K/max(K(:))); 
K = single(1./K); 
K = repmat(K(:), [1, nCh]);
K = single(K); 


end