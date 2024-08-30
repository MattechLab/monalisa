function out = bmImLaplaceIterator(imStart, m, nIter, varargin)
% out = bmImLaplaceIterator(imStart, m, nIter, varargin)
%
% This function iteratively solves the Laplace equation for the masked
% parts of the data (m = 0) using functions written in c++ to efficiently
% perform the computations. This is done to estimate and smooth the masked
% part of the data to match it to the unmasked data. The data can be 1D, 2D
% or 3D and openMP can be used for parallel processing.
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
%   imStart (array): Data of which the Laplace equation should be solved.
%   m (array): Mask that indicate which parts of the data should be kept
%    as the original data (m = 1) and for which parts the equation should be
%    solved (m = 1).
%   nIter (int): Number of iterations done in this function.
%   varargin{1}: Char or flag that allows parallized processing with
%    openMP. This is done if the value is 'omp' or true. Default value is
%    false.
%   varargin{2}: Integer giving the number of blocks processed by a thread.
%    Default value is the the max size of imStart -> all blocks in one
%    thread.
%
% Returns:
%   out (array): The data with the masked parts solved using an iterative
%    solver and the unmasked parts the same as the original data.

%% Initialize arguments
% Get original size
argSize = size(imStart); 

% Extract optional arguments
[omp_flag, nBlockPerThread] = bmVarargin(varargin);

% Set flag if omp_flag is a char
if ischar(omp_flag) 
    if strcmp(omp_flag, 'omp')
        omp_flag = true;
    else
        omp_flag = false;
    end
end

% Set default value
if isempty(omp_flag) 
    omp_flag = false;
end

% Set default value
if isempty(nBlockPerThread) 
    nBlockPerThread = int32(max(argSize(:)));
end

% Get dimension and size of input data (also get data as column vector if
% argIm is 1D) 
[imStart, imDim, imSize, sx, sy, sz] = bmImReshape(imStart);

% Check if the data is real
real_flag = isreal(imStart); 

% Set the correct format for the variables
imStart            = single(imStart);
m                  = logical(m);
m_neg              = logical(not(m));
nIter              = int32(nIter);
nBlockPerThread    = int32(nBlockPerThread);
sx                 = int32(sx);
sy                 = int32(sy);
sz                 = int32(sz);


%% Use c++ to solve the equation using iteration
if imDim == 1 % See imDim == 3 for comments
    if omp_flag
        if real_flag
            out = bmImLaplaceEquationSolver1_omp_mex(sx, imStart, m, nIter, nBlockPerThread);
        else
            out_real = bmImLaplaceEquationSolver1_omp_mex(sx, real(imStart), m, nIter, nBlockPerThread);
            out_imag = bmImLaplaceEquationSolver1_omp_mex(sx, imag(imStart), m, nIter, nBlockPerThread);
            out = complex(out_real, out_imag);
        end
    else
        if real_flag
            out = bmImLaplaceEquationSolver1_mex(sx, imStart, m, nIter);
        else
            out_real = bmImLaplaceEquationSolver1_mex(sx, real(imStart), m, nIter);
            out_imag = bmImLaplaceEquationSolver1_mex(sx, imag(imStart), m, nIter);
            out = complex(out_real, out_imag);
        end
    end
elseif imDim == 2 % See imDim == 3 for comments
    if omp_flag
        if real_flag
            out = bmImLaplaceEquationSolver2_omp_mex(sx, sy, imStart, m, nIter, nBlockPerThread);
        else
            out_real = bmImLaplaceEquationSolver2_omp_mex(sx, sy, real(imStart), m, nIter, nBlockPerThread);
            out_imag = bmImLaplaceEquationSolver2_omp_mex(sx, sy, imag(imStart), m, nIter, nBlockPerThread);
            out = complex(out_real, out_imag);
        end
    else
        if real_flag
            out = bmImLaplaceEquationSolver2_mex(sx, sy, imStart, m, nIter);
        else
            out_real = bmImLaplaceEquationSolver2_mex(sx, sy, real(imStart), m, nIter);
            out_imag = bmImLaplaceEquationSolver2_mex(sx, sy, imag(imStart), m, nIter);
            out = complex(out_real, out_imag);
        end
    end
elseif imDim == 3
    if omp_flag % Use openMP
        if real_flag % Real input data
            % Solve the Laplace equation on a 3D grid of real data by
            % iteration using OpenMP for parallel processing in c++
            out = bmImLaplaceEquationSolver3_omp_mex(sx, sy, sz, imStart, m, nIter, nBlockPerThread); 

        else  % Complex input data
            % Solve the Laplace equation on a 3D grid of real data by
            % iteration using OpenMP for parallel processing in c++, repeat
            % for imaginary part of the data
            out_real = bmImLaplaceEquationSolver3_omp_mex(sx, sy, sz, real(imStart), m, nIter, nBlockPerThread); 
            out_imag = bmImLaplaceEquationSolver3_omp_mex(sx, sy, sz, imag(imStart), m, nIter, nBlockPerThread);

            % Combine result back into a complex output array
            out = complex(out_real, out_imag); 
        end

    else % Don't use openMP
        if real_flag % Real input data
            % Solve the Laplace equation on a 3D grid of real data by
            % iteration in c++
            out = bmImLaplaceEquationSolver3_mex(sx, sy, sz, imStart, m, nIter); 

        else % Complex input data
            % Solve the Laplace equation on a 3D grid of real data by
            % iteration using in c++, repeat for imaginary part of the data
            out_real = bmImLaplaceEquationSolver3_mex(sx, sy, sz, real(imStart), m, nIter); 
            out_imag = bmImLaplaceEquationSolver3_mex(sx, sy, sz, imag(imStart), m, nIter);

            % Combine result back into a complex output array
            out = complex(out_real, out_imag);
        end
    end
end

% Reshape to original size
out = reshape(out, argSize);  

end


