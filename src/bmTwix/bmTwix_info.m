function bmTwix_info(myArg)
% bmTwix_info(myArg) 
% 
% Prints information included in the Siemens' raw data 
% file's Twix object used in the reconstruction process of the image.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   myArg (struct/char): Either the path to the Siemens' raw data file or 
%    a Twix object


if isa(myArg, 'char')
    % Read the twix object if path is given
    myTwix = mapVBVD_JH_for_monalisa(myArg);
    if iscell(myTwix)
        myTwix = myTwix{end};
    end
else
    myTwix = myArg; 
end



N       = []; 
nShot   = []; 
nLine   = []; 
nSeg    = []; 
nPar    = []; 
nCh     = []; 
nEcho   = []; 



hdr_Meas_ReadFoV        = []; 
hdr_Meas_FOV            = [];

hdr_Config_ReadFoV      = [];  
hdr_Config_PhaseFoV     = []; 
hdr_Config_PeFOV        = [];
hdr_Config_RoFOV        = []; 

hdr_Dicom_dPhaseFOV     = [];
hdr_Dicom_dReadoutFOV   = []; 

hdr_Protocol_ReadFoV    = [];
hdr_Protocol_PeFOV      = [];
hdr_Protocol_PhaseFoV   = []; 


%% header
N           = myTwix.image.NCol;
nShot       = myTwix.image.NSeg;
nLine       = myTwix.image.NLin;
nSeg        = nLine/nShot;
nPar        = myTwix.image.NPar; 
nEcho       = myTwix.image.NEco; 


if isfield(myTwix.hdr, 'Meas')
    if isfield(myTwix.hdr.Meas, 'ReadFoV')
        hdr_Meas_ReadFoV = myTwix.hdr.Meas.ReadFoV*2;
    end
    if isfield(myTwix.hdr.Meas, 'FOV')
        hdr_Meas_FOV = myTwix.hdr.Meas.FOV*2;
    end
end


if isfield(myTwix.hdr, 'Config')
    if isfield(myTwix.hdr.Config, 'ReadFoV')
        hdr_Config_ReadFoV      = myTwix.hdr.Config.ReadFoV*2;
    end
    if isfield(myTwix.hdr.Config, 'PhaseFoV')
        hdr_Config_PhaseFoV     = myTwix.hdr.Config.PhaseFoV*2;
    end
    if isfield(myTwix.hdr.Config, 'PeFOV')
        hdr_Config_PeFOV        = myTwix.hdr.Config.PeFOV*2;
    end
    if isfield(myTwix.hdr.Config, 'RoFOV')
        hdr_Config_RoFOV        = myTwix.hdr.Config.RoFOV*2;
    end
end


if isfield(myTwix.hdr, 'Dicom')
    if isfield(myTwix.hdr.Dicom, 'dPhaseFOV')
        hdr_Dicom_dPhaseFOV     = myTwix.hdr.Dicom.dPhaseFOV*2;
    end
    if isfield(myTwix.hdr.Dicom, 'dReadoutFOV')
        hdr_Dicom_dReadoutFOV   = myTwix.hdr.Dicom.dReadoutFOV*2;
    end
end



if isfield(myTwix.hdr, 'Protocol')
    if isfield(myTwix.hdr.Protocol, 'ReadFoV')
        hdr_Protocol_ReadFoV    = myTwix.hdr.Protocol.ReadFoV*2;
    end
    if isfield(myTwix.hdr.Protocol, 'PeFOV')
        hdr_Protocol_PeFOV   = myTwix.hdr.Protocol.PeFOV*2;
    end
    if isfield(myTwix.hdr.Protocol, 'PhaseFoV')
        hdr_Protocol_PhaseFoV   = myTwix.hdr.Protocol.PhaseFoV*2;
    end
end




%% data 
% unsorted() returns the unsorted data as an array [N, nCh, nLine]
y_raw = myTwix.image.unsorted();

% Change structure to [nCh, N, nLine]
y_raw = permute(y_raw, [2, 1, 3]);  

% Get nCh
y_raw_size = size(y_raw); 
y_raw_size = y_raw_size(:)'; 
nCh        = y_raw_size(1, 1);  

% Seperate nLine into nSeg and nShot (nSeg = nLine / nShot)
y_raw      = reshape(y_raw, [nCh, N, nSeg, nShot]); 

% Reduce the array to a 3D array, only containing the values for the first segment
mySI = squeeze(y_raw(:, :, 1, :));

% Calculate the inverse discret Fourier transform
mySI = bmIDF(mySI, 1, [], 2);

% Calculate the RMS along the first dimension (Coils) 
% -> magnitude spectrum of the signal
mySI = squeeze(  sqrt(sum(abs(mySI).^2, 1))  );

% Normalize the magnitude
mySI = mySI - min(mySI(:)); 
mySI = mySI/max(mySI(:)); 

% Create 2D array of size N x nShot with each column being [1; 2; ...; N]
mySize_1 = size(mySI, 1);
mySize_2 = size(mySI, 2);
x_SI = 1:mySize_1;
x_SI = repmat(x_SI(:), [1, mySize_2]);

% Calculate the weighted arithmetic mean and the weighted mean (COM)
s_mean = mean(x_SI.*mySI, 1);
s_center_mass = sum(x_SI.*mySI, 1)./sum(mySI, 1);

% Estimate shotOff (how many shots to be dropped)
window_size = 10;  % Define the size of the sliding window
threshold = std(s_mean)*0.1; %0.01 % Define a threshold for the std to consider steady state

% Compute the running standard deviation
running_std = movstd(s_mean, window_size);

% Find the shot where the standard deviation falls below the threshold
shotOff = find(running_std < threshold, 1);

%% Display information
% Print values 
fprintf('\n'); 
if isempty(N)
    fprintf('N     is empty. \n');
else
    fprintf('N     = %d \n', N);
end
if isempty(nSeg)
    fprintf('nSeg  is empty. \n');
else
    fprintf('nSeg  = %d \n', nSeg); 
end
if isempty(nShot)
    fprintf('nShot is empty. \n');
else
    fprintf('nShot = %d \n', nShot); 
end
if isempty(nLine)
    fprintf('nLine is empty. \n');
else
    fprintf('nLine = %d \n', nLine); 
end
if isempty(nPar)
    fprintf('nPar  is empty. \n');
else
    fprintf('nPar  = %d \n', nPar); 
end
if isempty(nCh)
    fprintf('nCh   is empty. \n');
else
    fprintf('nCh   = %d \n', nCh); 
end
if isempty(nEcho)
    fprintf('nEcho is empty. \n');
else
    fprintf('nEcho = %d \n', nEcho); 
end
fprintf('\n');


% Print FoV (Meas)
if isempty(hdr_Meas_ReadFoV)
    fprintf('hdr_Meas_ReadFoV       is empty. \n');
else
    fprintf('hdr_Meas_ReadFoV       = %4.2f \n', hdr_Meas_ReadFoV); 
end
if isempty(hdr_Meas_FOV)
    fprintf('hdr_Meas_FOV           is empty. \n');
else
    fprintf('hdr_Meas_FOV           = %4.2f \n', hdr_Meas_FOV); 
end
fprintf('\n');


% Print FoV (Config)
if isempty(hdr_Config_ReadFoV)
    fprintf('hdr_Config_ReadFoV       is empty. \n');
else
    fprintf('hdr_Config_ReadFoV     = %4.2f \n', hdr_Config_ReadFoV); 
end
if isempty(hdr_Config_PhaseFoV)
    fprintf('hdr_Config_PhaseFoV      is empty. \n');
else
    fprintf('hdr_Config_PhaseFoV    = %4.2f \n', hdr_Config_PhaseFoV); 
end
if isempty(hdr_Config_PeFOV)
    fprintf('hdr_Config_PeFOV         is empty. \n');
else
    fprintf('hdr_Config_PeFOV       = %4.2f \n', hdr_Config_PeFOV); 
end
if isempty(hdr_Config_RoFOV)
    fprintf('hdr_Config_RoFOV         is empty. \n');
else
    fprintf('hdr_Config_RoFOV       = %4.2f \n', hdr_Config_RoFOV); 
end
fprintf('\n');


% Print FoV (Dicom)
if isempty(hdr_Dicom_dPhaseFOV)
    fprintf('hdr_Dicom_dPhaseFOV      is empty. \n');
else
    fprintf('hdr_Dicom_dPhaseFOV    = %4.2f \n', hdr_Dicom_dPhaseFOV); 
end
if isempty(hdr_Dicom_dReadoutFOV)
    fprintf('hdr_Dicom_dReadoutFOV    is empty. \n');
else
    fprintf('hdr_Dicom_dReadoutFOV  = %4.2f \n', hdr_Dicom_dReadoutFOV); 
end
fprintf('\n');


% Print FoV (Protocol)
if isempty(hdr_Protocol_ReadFoV)
    fprintf('hdr_Protocol_ReadFoV   is empty. \n');
else
    fprintf('hdr_Protocol_ReadFoV   = %4.2f \n', hdr_Protocol_ReadFoV); 
end
if isempty(hdr_Protocol_PeFOV)
    fprintf('hdr_Protocol_PeFOV     is empty. \n');
else
    fprintf('hdr_Protocol_PeFOV     = %4.2f \n', hdr_Protocol_PeFOV); 
end
if isempty(hdr_Protocol_PhaseFoV)
    fprintf('hdr_Protocol_PhaseFoV  is empty. \n');
else
    fprintf('hdr_Protocol_PhaseFoV  = %4.2f \n', hdr_Protocol_PhaseFoV); 
end
fprintf('\n');


% Print shotOff value if found
if ~isempty(shotOff)
    fprintf('Steady state reached at shot %d\n', shotOff);
else
    fprintf('Steady state not reached within the data range.\n');
end
fprintf('\n');



% Plotting heatmap of magnitude for the first segment of each shot
figure('Name', 'TwixInfo Magnitude')
imagesc(mySI, [0, 3*mean(mySI(:))]); 
set(gca,'YDir','normal');
colorbar
colormap gray

% Plotting the mean and COM of each shot
hold on
plot(s_center_mass, 'g.-')
plot(s_mean, 'r.-')

% Plotting vertical line for shotOff
if ~isempty(shotOff)
    xline(shotOff, 'c--');  % Add vertical line at steady state index
    text(shotOff+5, floor(N*0.75), sprintf('shot = %i', ...
        shotOff), "HorizontalAlignment", "left", ...
        'Color', 'black', 'BackgroundColor', 'white', 'Margin', 0.5);
end

% Adding legend, title and labels
legend('Center of Mass', 'Mean', 'Steady State', 'Location', 'best')
xlabel('nShot')
ylabel('N','Rotation',0)
title(sprintf(['Magnitude spectrum for first segment of each shot\n(estimates ' ...
    'which shots should be excluded)']))


end