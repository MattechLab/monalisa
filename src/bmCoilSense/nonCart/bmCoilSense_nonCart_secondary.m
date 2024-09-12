function [C, varargout] = bmCoilSense_nonCart_secondary(y, C, y_ref, C_ref, Gn, Gu, Gut, ve, nIter, display_flag)
% [C, varargout] = bmCoilSense_nonCart_secondary(y, C, y_ref, C_ref, Gn,
%                                       Gu, Gut, ve, nIter, display_flag)
%
% This function uses a heuristic alternating gradient descent, between the
% reconstructed image x and the coil sensitivity C, to improve the
% estimation of the coil sensitivity map previously done. 
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
%   y (array): The acquired data of the surface coils in column format
%    [nPt, nCh].
%   C (array): The primary estimation of the coil sensitivity map for all
%    surface coils.
%   y_ref (array): The acquired data of the reference (body) coil.
%   C_ref (array): The estimation of the coil sensitivity of the reference
%    coil.
%   Gn (bmSparseMat): The approximate inverse mapping of the grid (backward
%   mapping).
%   Gu (bmSparseMat): The sparse matrix giving the forward mapping.
%   Gut (bmSparseMat): The transpose of Gu (backward mapping).
%   ve (array): Either an array containing the volume elements for each
%    point in the trajectory, for each point in the trajectory of each
%    channel or a skalar.
%   nIter (integer): Number of steps done in the gradient descent. 
%   display_flag (logical): Show image after every step if true.
%
% Returns:
%   C (array): The improved estimation of the coil sensitivity map for
%   every surface coil.
%   varargou{1}: Array containing the reconstructed combined image x.

%% Initialize arguments
% Magic number
nIterSmooth = 2; 

% Throw an error if y or y_ref are not of class single
if not(strcmp(class(y), 'single'))
    error('y must be of class ''single'' .');
end
if not(strcmp(class(y_ref), 'single'))
    error('y_ref must be of class ''single'' .');
end

% Extract "hidden" variables from arguments
N_u     = double(Gn.N_u(:)'); 
dK_u    = double(Gn.d_u(:)');
imDim   = size(N_u(:), 1); 

% Scale C such that the reference coil is as strong as all surface coils
% together
nCh_array   = size(y, 2); 
C           = C/nCh_array; 

% Set y_ref to be as strong as all other coils together
y_ref       = nCh_array*y_ref/bmY_norm(y_ref, ve)*mean(bmCol(bmY_norm(y, ve, false))); 

% Combine reference coil with surface coils and have them in column format
y           = cat(2, y_ref(:), y);   
C           = cat(2, C_ref(:), bmColReshape(C, N_u)); 

% Compute the image reconstructed by combining the data from all coils in
% column format 
x = bmColReshape(bmNasha(y, Gn, N_u, C), N_u); 

% Show reconstructed image
if display_flag 
    bmImage(bmBlockReshape(x, N_u))
end

% Get channels and resize ve to match the size of y
nCh         = size(y, 2); 
ve          = bmY_ve_reshape(ve, size(y)); 

% Get kernel matrix scaled by a factor F and one sclaed by F_conj
KF          = bmKF([],      N_u, N_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam); 
KF_conj     = bmKF_conj([], N_u, N_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam); 

% Prepare zero column vector
myZero      = zeros(prod(N_u(:)), 1);


%% Gradient descent
% Alternating gradient descent considering C or X as variables
% Solving modulus (FXC - y) Is to enhance C estimate
% euristic method.
for i=1:nIter
    
    % Image iteration
    % Calculate FXC and get the difference to y (cost)
    v = bmShanna(x, Gu, KF.*C, N_u, 'MATLAB') - y;

    % Calculate gradient partially by multiplying (FXC - y) with the
    % conjugate transpose of F -> F*(FXC - y)
    w = bmNakatsha(ve.*v, Gut, KF_conj, false, N_u, 'MATLAB'); 
    
    % Calculate gradient for A = FC (dx = 2C*F*(FCX - Y))
    d = 2*sum(conj(C).*w, 2);

    % Multiply it with A = FC to calculate stepsize
    Ad = bmShanna(d, Gu, KF.*C, N_u, 'MATLAB');

    % Calculate the stepsize and do a gradient descent step
    lambda = real(Ad(:)' * (ve(:).*v(:))) / real(Ad(:)' * (ve(:).*Ad(:)));
    x = x - lambda*d;
    % END image iteration
    
    % Coil iteration
    % Calculate gradient for A = FX (dC = 2X*F*(FXC - y))
    d_C = 2*repmat(conj(x), [1, nCh]).*w;

    % Don't change coil sensitivity of reference coil
    d_C(:, 1) = myZero; 

    % Multiply it with A = FX to calculate stepsize
    Ad_C = bmShanna(x, Gu, KF.*d_C, N_u, 'MATLAB');

    % Calculate the stepsize and do a gradient descent step
    lambda_C = real(Ad_C(:)' * (ve(:).*v(:))) / real(Ad_C(:)' * (ve(:).*Ad_C(:)));
    C = C - lambda_C*d_C; 
    % END coil iteration 
    
    % Show reconstructed image
    if display_flag
        bmImage(bmBlockReshape(x, N_u));
    end
    
    % Inform user about progress
    disp(['Iteration ', num2str(i), ' of gradient descent done.'])
end


%% Final adjustments
% Drop reference coil (body) from coil sensitvity map
C = C(:, 2:end); 
nCh = size(C, 2); 

% Change to block format
C = bmBlockReshape(C, N_u); 
x = bmBlockReshape(x, N_u); 

% Smooth the coil sensitivity in every channel
for i = 1:nCh
    if imDim == 1
        C(:, i) = bmImPseudoDiffusion(C(:, i), nIterSmooth);
    elseif imDim == 2
        C(:, :, i) = bmImPseudoDiffusion(C(:, :, i), nIterSmooth);
    elseif imDim == 3
        C(:, :, :, i) = bmImPseudoDiffusion(C(:, :, :, i), nIterSmooth);
    end
end

% Revert weighting of surface coils
C = C*nCh_array; 

% Return image data if required
if nargout > 1
    varargout{1} = x;
end

end