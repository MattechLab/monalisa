function Fx = bmDFT3(x, N_u, dK_u)
% Fx = bmDFT3(x, N_u, dK_u)
%
% This function computes the discrete Fourier transform for three 
% dimensional data using a fast Fourier transform (FFT) algorithm. 
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   x (3D array): Contains the data on which the FFT should be performed. 
%    The zero-frequency component is assumed to be in the center of x.
%   N_u (list): Contains the size of the grid.
%   dK_u (list): Contains the distances between grid points in every
%    dimension.
%
% Returns:
%   Fx (array): Contains the transformed data, having the same size as x.
%    The zero-frequency component is given in the center of Fx.

% Store the original size
argSize = size(x); 

% Reshape x to be seperated into blocks of size N_u ([96, 96, 96])
x = bmBlockReshape(x, N_u); 

% Calculate FFT for every dimension (assumes zero-frequency component to be
% in the center of x). Returns the zero-frequency component back into the
% center after doing FFT.
n = 1; 
x = fftshift(fft(ifftshift(x, n), [], n), n);
n = 2; 
x = fftshift(fft(ifftshift(x, n), [], n), n);
n = 3; 
x = fftshift(fft(ifftshift(x, n), [], n), n);

% The scaling factor accounts for the total number of points and the 
% spacing between points in the transformed domain.
F = prod(N_u(:))*prod(dK_u(:));

% Scale x by the factor F to properly normalize the FFT result
x = x/F; 

% Reshape to original size
Fx = reshape(x, argSize);

end