% Bastien Milani, September 2017
%
% This function returns the inverse discret fourrier transform 'iFf' of an
% input vector 'f' with grid 'k' or grid-step dK. The ifft function of
% matlab is used.
%
% f can be an array of any size.
% k must be a column or line array, and its length must be size(f, nDim).
% Or it can be a scalar, which is then interpreted as dK.
%
% nZero = varargin{1} is the number of zeros to add as zero-pading. Default
% value is nZero = 0; Default value is used if empty.
%
% nDim = varargin{2} is the dimension in which the fourrier transform is
% done. The default value is the first non-singelton dimension. Default
% value is used if empty.
%
% gridType = varargin{3} is the type of the grid k. Default value is 0 if k
% is odd-symmetric or 2 if k is even-assymetric-left-shifted. Default value
% is used if empty.
%
% The function is called by :  
% 
% [myIDF, x] = bmIDF(f, k, nZero, nDim, gridType);
%
% Example : myIDF = bmIDF(f, k);
% Example : myIDF = bmIDF(f, k, [], [],1);
% Example : myIDF = bmIDF(f, k, [], 4, 1);
% Example : myIDF = bmIDF(f, k, [], 4);
% Example : myIDF = bmIDF(f, k, 3*length(x), 4);
% Example : myIDF = bmIDF(f, k, 3*length(x));
% Example : [myIDF, x] = bmIDF(f, k, [], 6);
% Example : [myIDF, x, outGridType] = bmIDF(f, k, [], [], 3);

function [iFf, varargout] = bmIDF(f, k, varargin)


% argin_treatement --------------------------------------------------------

nDim = [];
if length(varargin) > 1
    nDim = varargin{2};
end
if isempty(nDim)
    nDim = 1;
    while (size(f, nDim) == 1) && (nDim < ndims(f))
        nDim = nDim + 1;
    end
    % in that case, nDim is now the first non-singelton dimension.
end

if isequal(size(k), [1, 1])
    dK = k;
    N = size(f, nDim);
    M = fix(N/2);
    k = -M*dK:dK:(N-1-M)*dK;
else
    k = k(:)';
end

nZero = 0;
if ~isempty(varargin)
    nZero = varargin{1};
end
if isempty(nZero)
    nZero = 0;
end
nZero = 2*fix(nZero/2); % consider always an even number of zero
% for zero-pading

gridType = [];
if length(varargin) > 2
    gridType = varargin{3};
end
if isempty(gridType)
    if abs(mean(k)) < abs(k(2) - k(1))/4
        gridType = 0;
    else
        gridType = 2;
    end
end

% end otpional_argument_treatment -----------------------------------------

% autofmatic_parameters ---------------------------------------------------
N = length(k);
dK = k(2) - k(1);
kMin = k(1);
kMax = k(end);
G = kMax - kMin + dK;
dX = 1/G;
% end automatic_parameters ------------------------------------------------

% check of the consitency between grid and gridType and size(f)------------
errorFlag = false;
if dK <= 0
    errorFlag = true;
end
if mod(N, 2) && (gridType ~= 0) && (gridType ~= 4)
    errorFlag = true;
end
if mod(N, 2) && (  abs(mean(k))>dK/4  ) && (gridType ~= 4)
    errorFlag = true;
end
if mod(N, 2) && (  abs(mean(k))<dK/4  ) && (gridType ~= 0) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (gridType ~= 1) && (gridType ~= 2) && (gridType ~= 3) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  abs(mean(k))>dK/4  ) && (gridType ~= 1) && (gridType ~= 2) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  abs(mean(k))<dK/4  ) && (gridType ~= 3) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  mean(k)>dK/4  ) && (gridType ~= 1) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  mean(k)<-dK/4  ) && (gridType ~= 2) && (gridType ~= 4)
    errorFlag = true;
end
if (  abs(mean(k))>dK*3/4  ) && (gridType ~= 4)
    errorFlag = true;
end
if length(k) ~= size(f, nDim)
    errorFlag = true;
end
if errorFlag
    error('The grid is not consitent with other inputs');
    return;
end
%end checks ---------------------------------------------------------------

% zero-pading -------------------------------------------------------------
if nZero > 0
    N = length(k) + nZero;
    dK = k(2) - k(1);
    kMin = k(1);
    kMax = k(end);
    k = (0:N-1)*dK + kMin - dK*nZero/2;
    kMin = k(1);
    kMax = k(end);
    G = kMax - kMin + dK;
    dX = 1/G;
    
    myZeroSize = size(f);
    myZeroSize(nDim) = nZero/2;
    f = cat(nDim, zeros(myZeroSize), f, zeros(myZeroSize));
end
if (N ~= size(f, nDim)) || (N ~= length(k))
    error('Problem in bmIDF. ')
    return;
end
% end zero-pading ---------------------------------------------------------

% applying_ifft -----------------------------------------------------------
if (gridType == 0) || (gridType == 2)
    
    iFf = fftshift(ifft(ifftshift(f, nDim), [], nDim), nDim)*N*dK;
    
    M = fix(N/2);
    xMin = -M*dX;
    xMax = (N-1-M)*dX;
    x = xMin:dX:xMax;
    
    if mod(N, 2)
        outGridType = 0;
    else
        outGridType = 2;
    end
    
elseif gridType == 1
    
    myShift = zeros(1, ndims(f));
    myShift(nDim) = 1;
    f = circshift(f, myShift);
    iFf = fftshift(ifft(ifftshift(f, nDim), [], nDim), nDim)*N*dK;
    iFf = circshift(iFf, -myShift);
    f = circshift(f, -myShift);
    
    M = fix(N/2);
    xMin = -(M-1)*dX;
    xMax =   M*dX;
    x = xMin:dX:xMax;
    outGridType = 1;
    
elseif gridType == 3
    
    M = fix(N/2);
    iFf = fftshift(ifft(ifftshift(f, nDim), [], nDim), nDim)*N*dK;
    
    % phase_correction ----------------------------------------------------
    myPhase = (-M:N-1-M)'/N;
    
    myPerm = 1:ndims(f);
    myPerm(1) = nDim;
    myPerm(nDim) = 1;
    mySize = size(f);
    mySize = mySize(myPerm);
    mySize = mySize(2:end);
    myPhase = repmat(myPhase, [1, mySize]);
    myPhase = permute(myPhase, myPerm);
    
    iFf = exp(1i*pi*myPhase).*iFf;
    % end phase_correction ------------------------------------------------
    
    xMin = -M*dX;
    xMax = (N-1-M)*dX;
    x = xMin:dX:xMax;
    outGridType = 2;
    
elseif gridType == 4
    
    M = fix(N/2);
    iFf = fftshift(ifft(f, [], nDim), nDim)*N*dK;
    
    % phase_correction ----------------------------------------------------
    myPhase = (-M:N-1-M)';
    
    myPerm = 1:ndims(f);
    myPerm(1) = nDim;
    myPerm(nDim) = 1;
    mySize = size(f);
    mySize = mySize(myPerm);
    mySize = mySize(2:end);
    myPhase = repmat(myPhase, [1, mySize]);
    myPhase = permute(myPhase, myPerm);
    
    iFf = exp(1i*2*pi*k(1)*dX*myPhase).*iFf;
    % end phase_correction ------------------------------------------------
    
    xMin = -M*dX;
    xMax = (N-1-M)*dX;
    x = xMin:dX:xMax;
    
    if mod(N, 2)
        outGridType = 0;
    else
        outGridType = 2;
    end
    
end
% end applying_ifft -------------------------------------------------------

% filling_optional_outputs ------------------------------------------------
varargout{1} = x;
varargout{2} = outGridType;
% end filling_optional_outputs --------------------------------------------

end
