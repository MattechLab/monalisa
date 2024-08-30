function [y_ref, C_ref] = bmCoilSense_nonCart_ref(y, Gn, m, nSmooth_phi)
% [y_ref, C_ref] = bmCoilSense_nonCart_ref(y, Gn, m, nSmooth_phi)
%
% This function uses the data given in y to create a reference that can be
% used to estimate the coil sensitvity of the surface coils. Using the mask
% that indicates the good pixels of the data, a Laplace solver algorithm is
% used to estimate the coil senstivity of the reference coil for the masked
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
%   y (array): The acquired data of at least one reference coil. Complex
%    and in col format (nPt, nCh).
%   Gn (bmSparseMat): Sparse matrix of class bmSparseMat that grids the
%    non-uniform data (y) onto a uniform grid. 
%   m (array): A mask of the same size as the datapoints in a channel,
%    which indicates the good data (pixels) with a 1 (or true).
%   nSmooth_phi (int): The number of iterations for pseudo diffusing the
%    complex data, resulting in the coil sensitvity being a complex array.
%    If this is not wanted (WHICH IT IS FOR ALL USES ATM) please use [].
%
% Returns:
%   y_ref (list): Column vector containing the acquired data in k-space of
%    the reference coil chosen.
%   C_ref (array): The estimated coil sensitvity of the chosen reference
%    coil, given in block format.
%
% Notes:
%   The data in y should be acquired using body coils.
%   The assumption can be made that C_ref is more uniform and can be
%   estimated by diffusing and smoothing the data devided by the RMS
%   instead of the image (C_ref = I_ref / I_anat, I_anat assumed to be
%   similar to RMS)

%% Initialize arguments
% Magic numbers
L_nIter = 1000;
L_th    = 1e-4;
nIter_smooth = 2;

% Extract "hidden" variables from arguments
N_u         = double(Gn.N_u(:)');
nPt         = double(Gn.r_size); 
imDim       = size(N_u(:), 1);
nCh         = size(y(:), 1)/nPt;

% Prepare masks for one channel
m           = logical(reshape(m, N_u)); 
m_neg       = not(m); 

% Change mask to column format and repeat for every channel
m_rep       = repmat(m(:), [1, nCh]); 
m_neg_rep   = not(m_rep); 


%% Compute data
% Compute the regridded data in the image space for the reference coils
% in the column format and set the masked parts to 1
x_ch            = single(bmColReshape(bmNasha(y, Gn, N_u), N_u)); 
x_ch(m_neg_rep) = 1;

% Change data to block format
x_ch            = bmBlockReshape(x_ch, N_u); 

% Calculate the RMS across all channels -> Assume to be close to the actual
% anatomical image
myRMS           = bmRMS(x_ch, N_u); 


% Initialize complex array for coil sensitvity of each reference coil
z     = zeros([N_u, nCh], 'single');
C     = complex(z, z);


%% Compute coil sensitivity of refrence coils
for i = 1:nCh
    if imDim == 1 % See imDim == 3 for comments
        
        temp_a = x_ch(:, i);
        C_abs = bmImPseudoDiffusion_inMask(abs(temp_a)./myRMS, m, nIter_smooth); 
        
        if not(isempty(nSmooth_phi))
            C_phi = angle(bmImPseudoDiffusion_inMask(temp_a, m, nSmooth_phi));
        else
            C_phi = zeros(size(temp_a)); 
        end
        
        temp_C = C_abs.*exp(1i*C_phi);
        temp_C(m_neg) = 0; 
        C(:, i) = bmImLaplaceEquationSolver(temp_C, m, L_nIter, L_th, 'omp'); 

    elseif imDim == 2 % See imDim == 3 for comments
        
        temp_a = x_ch(:, :, i);
        C_abs = bmImPseudoDiffusion_inMask(abs(temp_a)./myRMS, m, nIter_smooth); 
        
        if not(isempty(nSmooth_phi))
            C_phi = angle(bmImPseudoDiffusion_inMask(temp_a, m, nSmooth_phi));
        else
            C_phi = zeros(size(temp_a)); 
        end
        
        temp_C = C_abs.*exp(1i*C_phi); 
        temp_C(m_neg) = 0; 
        C(:, :, i) = bmImLaplaceEquationSolver(temp_C, m, L_nIter, L_th, 'omp');  
        
    elseif imDim == 3
        % Get data of one channel
        temp_a = x_ch(:, :, :, i);

        % Diffuse magnitude of unmasked data (m = 1) by averaging over
        % neighbors, with the data devided by the image estimate (RMS)
        % C_ref = I_ref / I_real
        C_abs = bmImPseudoDiffusion_inMask(abs(temp_a)./myRMS, m, nIter_smooth); 

        if not(isempty(nSmooth_phi))
            % Get the angle of smoothed data if nSmooth_phi is not empty
            C_phi = angle(bmImPseudoDiffusion_inMask(temp_a, m, nSmooth_phi));
        else
            % Use zeros otherwise (real number)
            C_phi = zeros(size(temp_a)); 
        end
        
        % Return back to a complex number if C_phi is not zero and set
        % masked parts to zero
        temp_C = C_abs.*exp(1i*C_phi); 
        temp_C(m_neg) = 0;
        
        % Solve a Laplacian solver to estimate the coil sensitivity for the
        % masked data (smooth masked parts)
        C(:, :, :, i) = bmImLaplaceEquationSolver(temp_C, m, L_nIter, L_th, 'omp');

    end
end


%% Select and return reference data and coil sensitivity
% Reshape data and coil sensitvity to column format
x_ch   = bmColReshape(x_ch, N_u); 
C      = bmColReshape(C, N_u); 


% C_ref and y_ref only take data of one reference coil
C_ref = C(:, 1); 
y_ref = y(:, 1); 


% Reshape reference coil sensitivity to column format
C_ref = bmBlockReshape(C_ref, N_u);  

end

