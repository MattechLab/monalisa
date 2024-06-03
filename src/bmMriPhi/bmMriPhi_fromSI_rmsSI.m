% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function rmsSI = bmMriPhi_fromSI_rmsSI(argSI, nCh, N, nShot)

SI = reshape(argSI, [nCh ,N, nShot]);
rmsSI = squeeze(sqrt(  mean(abs(SI).^2, 1)  ));
rmsSI = rmsSI - min(rmsSI(:));
rmsSI = rmsSI/max(rmsSI(:));

end