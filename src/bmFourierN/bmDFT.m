% Bastien Milani, September 2017
%
% This function returns the discret fourrier transform 'Ff' of an
% input vector 'f' with grid 'x' or grid-step dX. The fft function of
% matlab is used.
%
% f can be an array of any size.
% x must be a column or line array, and its length must be size(f, nDim).
% Or it can be a scalar, which is then interpreted as dX.
%
% nZero = varargin{1} is the number of zeros to add as zero-pading. Default
% value is nZero = 0; Default value is used if empty.
%
% nDim = varargin{2} is the dimension in which the fourrier transform is
% done. The default value is the first non-singelton dimension. Default
% value is used if empty.
%
% gridType = varargin{3} is the type of the grid x. Default value is 0 if x
% is odd-symmetric or 2 if x is even-assymetric-left-shifted. Default value
% is used if empty.
%
% The function is called by :  
% 
% [myDF, k] = bmDFT(f, x, nZero, nDim, gridType);
%
% Example : myDF = bmDFT(f, x);
% Example : myDF = bmDFT(f, x, [], [],1);
% Example : myDF = bmDFT(f, x, [], 4, 1);
% Example : myDF = bmDFT(f, x, [], 4);
% Example : myDF = bmDFT(f, x, 3*length(x), 4);
% Example : myDF = bmDFT(f, x, 3*length(x));
% Example : [myDF, k] = bmDFT(f, x, [], 6);
% Example : [myDF, k, outGridType] = bmDFT(f, x, [], [], 3);

function [Ff, varargout] = bmDFT(f, x, varargin)

% argin_treatement --------------------------------------------------------

nDim = [];
if length(varargin) > 1
    nDim = varargin{2};
end
if isempty(nDim)
    nDim = 1;
    while (size(f, nDim) == 1) && (nDim < ndims(f));
        nDim = nDim + 1;
    end
    % in that case, nDim is now the first non-singelton dimension.
end

if isequal(size(x), [1, 1])
    dX = x;
    N = size(f, nDim);
    M = fix(N/2);
    x = -M*dX:dX:(N-1-M)*dX;
else
    x = x(:)';
end

nZero = [];
if length(varargin) > 0
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
    if abs(mean(x)) < abs(x(2) - x(1))/4
        gridType = 0;
    else
        gridType = 2;
    end
end

% end argin_treatement ----------------------------------------------------

% autofmatic_parameters ---------------------------------------------------
N = length(x);
dX = x(2) - x(1);
xMin = x(1);
xMax = x(end);
L = xMax - xMin + dX;
dK = 1/L;
% end automatic_parameters ------------------------------------------------

% check of the consitency between grid and gridType and size(f)------------
errorFlag = false;
if dX <= 0
    errorFlag = true;
end
if mod(N, 2) && (gridType ~= 0) && (gridType ~= 4)
    errorFlag = true;
end
if mod(N, 2) && (  abs(mean(x))>dX/4  ) && (gridType ~= 4)
    errorFlag = true;
end
if mod(N, 2) && (  abs(mean(x))<dX/4  ) && (gridType ~= 0) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (gridType ~= 1) && (gridType ~= 2) && (gridType ~= 3) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  abs(mean(x))>dX/4  ) && (gridType ~= 1) && (gridType ~= 2) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  abs(mean(x))<dX/4  ) && (gridType ~= 3) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  mean(x)>dX/4  ) && (gridType ~= 1) && (gridType ~= 4)
    errorFlag = true;
end
if (mod(N, 2) == 0) && (  mean(x)<-dX/4  ) && (gridType ~= 2) && (gridType ~= 4)
    errorFlag = true;
end
if (  abs(mean(x))>dX*3/4  ) && (gridType ~= 4)
    errorFlag = true;
end
if length(x) ~= size(f, nDim)
    errorFlag = true;
end
if errorFlag
    error('The grid is not consitent with other inputs');
    return;
end
%end checks ---------------------------------------------------------------

% zero-pading -------------------------------------------------------------
if nZero > 0
    N = length(x) + nZero;
    dX = x(2) - x(1);
    xMin = x(1);
    xMax = x(end);
    x = (0:N-1)*dX + xMin - dX*nZero/2;
    xMin = x(1);
    xMax = x(end);
    L = xMax - xMin + dX;
    dK = 1/L;
    
    myZeroSize = size(f);
    myZeroSize(nDim) = nZero/2;
    f = cat(nDim, zeros(myZeroSize), f, zeros(myZeroSize));
end
if (N ~= size(f, nDim)) || (N ~= length(x))
    error('Problem in bmIDF. ')
    return;
end
% end zero-pading ---------------------------------------------------------

% applying_fft ------------------------------------------------------------
if (gridType == 0) || (gridType == 2)
    
    Ff = fftshift(fft(ifftshift(f, nDim), [], nDim), nDim)*dX;
    
    M = fix(N/2);
    kMin = -M*dK;
    kMax =  (N-1-M)*dK;
    k = kMin:dK:kMax;
    
    if mod(N, 2)
        outGridType = 0;
    else
        outGridType = 2;
    end
    
elseif gridType == 1
    
    myShift = zeros(1, ndims(f));
    myShift(nDim) = 1;
    f = circshift(f, myShift);
    Ff = fftshift(fft(ifftshift(f, nDim), [], nDim), nDim)*dX;
    Ff = circshift(Ff, -myShift);
    f = circshift(f, -myShift);
    
    M = fix(N/2);
    kMin = -(M-1)*dK;
    kMax =   M*dK;
    k = kMin:dK:kMax;
    outGridType = 1;
    
elseif gridType == 3
    
    M = fix(N/2);
    Ff = fftshift(fft(ifftshift(f, nDim), [], nDim), nDim)*dX;
    
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
    
    Ff = exp(-1i*pi*myPhase).*Ff;
    % end phase_correction ------------------------------------------------
    
    kMin = -M*dK;
    kMax = (N-1-M)*dK;
    k = kMin:dK:kMax;
    outGridType = 2;
    
elseif gridType == 4
    
    M = fix(N/2);
    Ff = fftshift(fft(f, [], nDim), nDim)*dX;
    
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
    
    Ff = exp(-1i*2*pi*x(1)*dK*myPhase).*Ff;
    % end phase_correction ------------------------------------------------
    
    kMin = -M*dK;
    kMax = (N-1-M)*dK;
    k = kMin:dK:kMax;
    
    if mod(N, 2)
        outGridType = 0;
    else
        outGridType = 2;
    end
    
end
% end applying_fft --------------------------------------------------------

% filling_optional_outputs ------------------------------------------------
varargout{1} = k;
varargout{2} = outGridType;
% end filling_optional_outputs --------------------------------------------

end
