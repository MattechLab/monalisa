function out = bmImLaplacian(argIm)
% out = bmImLaplacian(argIm)
%
% This function efficiently calculates the Laplacian of the given 1D, 2D,
% 3D, real or complex data.
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
%   argIm (array): The data of which the Laplacian should be calculated.
%
% Returns:
%   out (array): The Laplacian of the data (same size as argIm).

% Get original size
argSize = size(argIm);

% Get dimension and size of input data (also get data as column vector if
% argIm is 1D)
[argIm, imDim, ~, sx, sy, sz] = bmImReshape(argIm); 

% Check if the data is real
real_flag = isreal(argIm); 

% Set the correct format for the variables
argIm     = single(argIm);
sx        = int32(sx);
sy        = int32(sy);
sz        = int32(sz);

if imDim == 1 % See imDim == 3 for comments
    if real_flag
        out = bmImLaplacian1_mex(sx, argIm);

    else
        out_real = bmImLaplacian1_mex(sx, real(argIm));
        out_imag = bmImLaplacian1_mex(sx, imag(argIm));
        out = complex(out_real, out_imag);
    end

elseif imDim == 2 % See imDim == 3 for comments
    if real_flag
        out = bmImLaplacian2_mex(sx, sy, argIm);

    else
        out_real = bmImLaplacian2_mex(sx, sy, real(argIm));
        out_imag = bmImLaplacian2_mex(sx, sy, imag(argIm));
        out = complex(out_real, out_imag);
    end

elseif imDim == 3
    if real_flag
        % Efficiently compute the Laplacian of a real 3D data in c++
        out = bmImLaplacian3_mex(sx, sy, sz, argIm); 

    else
        % Efficiently compute the Laplacian of real 3D data in c++,
        % repeat for the imaginary part 
        out_real = bmImLaplacian3_mex(sx, sy, sz, real(argIm));
        out_imag = bmImLaplacian3_mex(sx, sy, sz, imag(argIm));

        % Combine results in a complex output array
        out = complex(out_real, out_imag); 
    end
end

% Reshape to original size
out = reshape(out, argSize); 


end