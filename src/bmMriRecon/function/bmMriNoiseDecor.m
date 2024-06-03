% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


% noise_meas is the noise measurment performed during prescan. It must be
% in the size [nPt_noise, nCh] i.e. channel dimension as second dimension. 
%
% y is the complex-valued raw_data and must be in the size [nPt, nCh]; 
%
% C is the comlex-valued coil_sense. Lowres preferably in order to 
% accelerate the calculation. 
%
% C_n_u is the image size of the (lowres) coil_sense. For example if 
% size(C) = [64, 96, 128, 24] (i.e. 24 channels), then is 
% C_n_u = [64, 96, 128] because the image size is [64, 96, 128] in that
% case. 


function [y_decor, C_decor] = bmMriNoiseDecor(noise_meas, y, C, C_n_u)


% initial -----------------------------------------------------------------

nCh         = size(noise_meas, 2); 
nPt_noise   = size(noise_meas, 1); 

C = bmColReshape(C, C_n_u); 
C_size = size(C); 
C_size = C_size(:)'; 

C_decor = bmZero(size(C), 'complex_single'); 
if iscell(y)
    nCell   = size(y(:)); 
    y_decor = cell(size(y)); 
    for i = 1:nCell       
        y_decor{i} = bmZero(size(y{i}), 'complex_single'); 
    end
else
    y_decor = bmZero(size(y), 'complex_single'); 
end

% checking_argins
if ~isequal(nCh, C_size(1, end))
    error('There is a problem with the size of noise_meas and/or with the size of C'); 
    return; 
end

nPt_noise = size(noise_meas, 1); 
if nPt_noise <= nCh
    error('There is a problem with the size of noise_mease. '); 
    return; 
end
% END_checking_argins

disp('Starting noise_decorrelation ... '); 

% END_initial -------------------------------------------------------------







% noise_correlation_matrix_and_cholesky_decomposition ---------------------

psi = (1/(nPt_noise-1))*noise_meas'*noise_meas; % noise_correlation_matrix

for i = 1:nCh
    % cleaning imaginary part coming from trucation errors
    psi(i, i) = real(psi(i, i)); 
end

% Cholesky decomposition of psi
L = chol(psi, 'lower'); 

% taking inverse
L_inv = inv(L); 

% normalizing by SOS of diagonal elements in order to approx conserve magnitude
L_inv = L_inv/sqrt(mean(abs(  diag(L_inv)  ).^2)); 

% END_noise_correlation_matrix_and_cholesky_decomposition -----------------






% noise_decorrelation -----------------------------------------------------
if iscell(y)
    nCell   = size(y(:)); 
    for i = 1:nCell
        
       for k = 1:nCh
           for m = 1:nCh
                y_decor{i}(:, k) = y_decor{i}(:, k) + L_inv(k, m)*y{i}(:, m);  
           end
       end
       
    end
else
    
    for k = 1:nCh
        for m = 1:nCh
            y_decor(:, k) = y_decor(:, k) + L_inv(k, m)*y(:, m);
        end
    end
    
end

for k = 1:nCh
    for m = 1:nCh
        C_decor(:, k) = C_decor(:, k) + L_inv(k, m)*C(:, m);
    end
end
% END_noise_decorrelation -----------------------------------------------------




% final -------------------------------------------------------------------
C_decor = bmBlockReshape(C_decor, C_n_u); 
disp('... noise_decorrelation done. '); 
% END_final ---------------------------------------------------------------



end