function x = bmCoilSense_pinv(C, x0, n_u)
% x = bmCoilSense_pinv(C, x0, n_u)
%
% This function performs image reconstruction using coil sensitivity
% profiles and a pseudoinverse.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   C (array): The coil sensitivity of each coil. Has the same amount of
%    points as the data.
%   x0 (array): The data acquired by each coil. Has the same amount of
%    points as C.
%   n_u (list): The size of the grid.
%
% Returns:
%   x (array): The reconstructed image by combining the data of all coils.
%    This is given in the block format.
% 
% Notes:
%   The reconstruction is done by multiplying the pseudoinverse of the coil
%   sensitivity profiles with the recorded data.
%   This comes from x0 = C * x -> x = (C*C)^-1 * (C*) * x0, with C* being
%   the conjugate transpose of C and * being the matrix multiplication.
%   C is a diagonal matrix (in theory, not matlab implementation) 

% Change to column format
C       = single(bmColReshape(C, n_u)); 
x0      = single(bmColReshape(x0, n_u)); 

% Reconstructing the image -> nominator: (C*) * x0 (sum combines coil
% images), denominator: (C*C)^-1
x       = sum(conj(C).*x0, 2)./sum(abs(C).^2, 2);

% Change to block format
x       = bmBlockReshape(x, n_u); 

end