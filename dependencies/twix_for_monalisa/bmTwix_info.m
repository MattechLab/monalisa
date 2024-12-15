function bmTwix_info(myArg)

if isa(myArg, 'char')
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


% header ------------------------------------------------------------------
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


% END_header --------------------------------------------------------------





% data --------------------------------------------------------------------
y_raw = myTwix.image.unsorted();
y_raw = permute(y_raw, [2, 1, 3]);  

y_raw_size = size(y_raw); 
disp(y_raw_size);

y_raw_size = y_raw_size(:)'; 
nCh        = y_raw_size(1, 1);  
nLin = y_raw_size(1,3);
nSeg = round(nSeg);
nShot = floor(nLin/nSeg);
new_Lin = floor(nLin/nSeg)*nSeg;
y_raw = y_raw(:,:,1:new_Lin);
disp(size(y_raw))
% disp(['nCh, N, nSeg, nShot', num2str(nCh),' ', num2str(N),' ', num2str(nSeg),' ', num2str(nShot)]);
y_raw      = reshape(y_raw, [nCh, N, nSeg, nShot]); 

mySI = squeeze(y_raw(:, :, 1, :));
mySI = bmIDF(mySI, 1, [], 2);
mySI = squeeze(  sqrt(sum(abs(mySI).^2, 1))  ); 
mySI = mySI - min(mySI(:)); 
mySI = mySI/max(mySI(:)); 

mySize_1 = size(mySI, 1);
mySize_2 = size(mySI, 2);
x_SI = 1:mySize_1;
x_SI = repmat(x_SI(:), [1, mySize_2]);

s_mean = mean(x_SI.*mySI, 1);
s_center_mass = sum(x_SI.*mySI, 1)./sum(mySI, 1);
% END_data ----------------------------------------------------------------




% display -----------------------------------------------------------------

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



figure
hold on
imagesc(mySI); 
colormap gray
plot(s_center_mass, 'y.-')
plot(s_mean, 'r.-')
caxis([0, 3*mean(mySI(:))])

% END_display -------------------------------------------------------------


end