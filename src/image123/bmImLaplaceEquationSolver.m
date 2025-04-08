function out = bmImLaplaceEquationSolver(imStart, m, nIter, L_th, varargin)
% out = bmImLaplaceEquationSolver(imStart, m, nIter, L_th, varargin)
%
% This function solves a Laplace equation by iteration to estimate the
% values of the image at the masked parts (m = 0). After nIter iterations
% the residual is compared to the given threshold to decide if the solution
% converged enough in the masked parts. This indicates that no rough places
% or edges exist anymore. This function is used to estimate the coil
% sensitivity at the masked parts of the data.
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
%   imStart (array): Real or complex data of which the masked parts should
%   be estimated.
%   m (array): Mask with the same size as imStart (masked where m = 0).
%   nIter (int): Number of iterations before the result is checked.
%   L_th (double): Threshold for the residual to determine if the solution
%   converged enough.
%   varargin{1}: Flag; use openMP for parallel processing if true. Default
%   value is [] (false)
%   varargin{1}: Number of blocks per thread (not used atm).
%
% Returns:
%   out (array): Estimate for the coil sensitvity at the masked parts of
%   the data. The unmasked parts have the original data values.


% Extract optional arguments
[omp_flag, nBlockPerThread] = bmVarargin(varargin);

% Set up variables
m_neg       = not(m); 
out         = imStart;
myCondition = true;

% Iterate until condition is met
while myCondition
    % Average the masked data iteratively over their neighbors, keep the 
    % unmasked parts at their original value
    out = bmImLaplaceIterator(out, m, nIter, omp_flag, nBlockPerThread); 

    % Compute the Laplacian of the whole data to see how much the data 
    % deviates from their neighbors
    L   = bmImLaplacian(out); 
    
    
    % We only care about the masked part of the data
    L_squared_norm  = sum(abs(    L(m_neg(:))  ).^2); 
    im_squared_norm = sum(abs(  out(m_neg(:))  ).^2);

    % Calculate residual to measure overall change in the solution within 
    % the masked region -> how smooth it is (L -> 0 for smooth data)
    r = sqrt(L_squared_norm/im_squared_norm); 

    % Check if the solution is stabilizing 
    % (changes are getting smaller -> converge)
    myCondition = (r > L_th); 
    
end

end
