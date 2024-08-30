function C = bmCoilSense_nonCart_primary(y, y_ref, C_ref, Gn, ve, m)
% C = bmCoilSense_nonCart_primary(y, y_ref, C_ref, Gn, ve, m)
%
% This function estimates the coil sensitivity of all surface coils using
% the coil sensitvity and data of the reference coil. Using the mask
% that indicates the good pixels of the data, a Laplace solver algorithm is
% used to estimate the coil senstivity of the surface coils for the masked
% parts (m = 0).
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
%   y (array): The data of the surface coils. Has the size (nPt, nCh).
%   y_ref (array): The column vector containing the data of the reference
%    coil.
%   C_ref (array): The coil sensitivity of the reference coil. Has the size
%    of Gn.N_u (block format).
%   Gn (bmSparseMat): The sparse matrix used to grid the non-uniform data
%    to a uniform grid.
%   ve (array): The volume elements for each point in y. Can be the size of
%    one channel, a scalar or the size of y.
%   m (array): The mask that masks the data that is not usefull with m = 0.
%    Has the size of one channel in block format.
%
% Returns:
%   C (array): The coil sensitvity of all surface coils (channels) in block
%    format.


%% Initialize arguments
% Magic numbers
nIter_smooth = 2;
L_nIter = 1000;
L_th = 1e-4;

% Extract "hidden" variables from arguments
N_u         = double(Gn.N_u(:)');
nPt         = double(Gn.r_size);
imDim       = size(N_u(:), 1);  
nCh         = size(y(:), 1)/nPt;

nCh_array   = size(y, 2);  

% Set y_ref to the same scale as y (make them comparable)
y_ref       = nCh_array*y_ref/bmY_norm(y_ref, ve)*mean(bmCol(bmY_norm(y, ve, false))); 


% Compute the regridded data in the image space for the refrence body coil
% in block format 
x_ref       = bmBlockReshape(bmNasha(y_ref, Gn, N_u), N_u); 

% Compute the regridded data in the image space for all surface coils in
% block format 
x           = bmBlockReshape(bmNasha(y, Gn, N_u),     N_u); 


% Have the mask in block format and get its negative
m           = logical(bmBlockReshape(m, N_u)); 
m_neg       = not(m); 

% Calculate the estimated anatomical image from the reference coil and set
% masked parts to 1
anat_ref    = x_ref./C_ref; 
anat_ref(m_neg) = 1; 

% Initialize complex array for coil sensitvity of each surface coil
z = zeros([N_u, nCh], 'single'); 
C = complex(z, z); 


%% Compute coil sensitivity
% For each channel (surface coil) channel compute the coil sensitivity
for i = 1:nCh    
    if imDim == 1 % See imDim == 3 for comments
        temp_im = x(:, i);
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat_ref, m, nIter_smooth); 
        temp_im(m_neg) = 0;
        C(:, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');
        
    elseif imDim == 2 % See imDim == 3 for comments
        temp_im = x(:, :, i);  
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat_ref, m, nIter_smooth);
        temp_im(m_neg) = 0; 
        C(:, :, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');

    elseif imDim == 3 
        % Get data of a channel
        temp_im = x(:, :, :, i); 
        
        % Diffuse magnitude of unmasked data (m = 1) by averaging over
        % neighbors, with the data devided by the image estimate
        % C_coil = I_coil / I_real
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat_ref, m, nIter_smooth);

        % Solve a Laplacian solver to estimate the coil sensitivity for the
        % masked data (smooth masked parts)
        temp_im(m_neg) = 0;
        C(:, :, :, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');
        
    end
end

% Scale and reshape the coil sensitvity to block format
C = C*nCh_array; 
C = bmBlockReshape(C, N_u); 

end