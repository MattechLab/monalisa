%% Setting Path

% This should store the path to the monalisa directory in the variable 
% 'monalisa_dir'. If it does not work just do it manually.  
[monalisa_dir, ~, ~] = fileparts(  matlab.desktop.editor.getActiveFilename  ); 
for i = 1:3
    [monalisa_dir, ~, ~] = fileparts(monalisa_dir); 
end

% Add the paths to all Monalisa subdirectories.  
src_dir = [monalisa_dir, filesep, 'src']; 
addpath(genpath(src_dir));


%% preparing data for simulation

N_u         = [64, 64]; 
dK_u        = 1./[200, 200]; % arbitrary FoV 
nCh         = 16; 
calib_size  = 32; % Define the calibration size

h           = phantom(N_u(1, 1)); % Create the phantom image
C           = bcaNeith_coilSensitivitySimulation2(N_u(1, 1), N_u(1, 2), nCh);
kspace      = bmDFT2(repmat(h, [1, 1, nCh]).*C, N_u, dK_u); % Create the simulated 
                                                            % k-space with coil sensitivities
                                                            
umask               = ones(N_u);  % Create the undersampling mask (2x2 undersampling)
umask(1:2:end,:)    = 0;
umask(:,2:2:end)    = 0;

calib               = kspace((N_u(1, 1)/2-calib_size/2+1):(N_u(1, 1)/2+calib_size/2),:,:); % Extract the calibration data
undersampled_kspace = repmat(umask, [1, 1, nCh]).*kspace; % Undersampling the data


%% Call of GRAPPA implementation
filled_kspace = bcaNeith2(undersampled_kspace,calib,[5,5]); 

%% recon and plots

% recon
x_grappa    = bmIDF2(filled_kspace,          N_u, dK_u);
x_zero      = bmIDF2(undersampled_kspace,    N_u, dK_u);

% coil_combine
x_grappa    = bmCoilSense_pinv(C, x_grappa, N_u); 
x_zero      = bmCoilSense_pinv(C, x_zero,   N_u); 

% plots
figure
subplot(2,3,1)
imagesc(abs(squeeze(kspace(:,:,1)))), axis image, axis off, colormap gray
title('Original k-space')

subplot(2,3,3)
imagesc(1*umask), axis image, axis off, colormap gray
title('Undersampling mask')


subplot(2,3,2)
imagesc(abs(squeeze(undersampled_kspace(:,:,1)))), axis image, axis off, colormap gray
title('Undersampled k-space')


subplot(2,3,4)
imagesc(abs(h)), axis image, axis off, colormap gray
title('Original image')


subplot(2,3,5)
imagesc(abs(x_zero(:,:,1))), axis image, axis off, colormap gray
title('Undersampled image')


subplot(2,3,6)
imagesc(abs(x_grappa(:,:,1))), axis image, axis off, colormap gray
title('GRAPPA reconstruction')




