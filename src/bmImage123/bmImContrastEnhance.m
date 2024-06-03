% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImContrastEnhance(argIm, enhence_factor)

myPlus = 10;  % -------------------------------------------------------------- magic number
mySmall = 0.1; % ------------------------------------------------------------- magic number

[argIm, imDim, imSize] = bmImReshape(argIm); 

myMean_0 = mean(argIm(:));
plus_flag = false; 
if abs(myMean_0) < mySmall 
    argIm = argIm + myPlus;
    myMean_0 = mean(argIm(:)); 
    plus_flag = true; 
end

if imDim == 1
    
    [F, kx] = bmImDFT(argIm);
    [kx] = ndgrid(kx);
    n = sqrt(kx.^2); 
    
elseif imDim == 2
    
    [F, kx, ky] = bmImDFT(argIm);
    [kx, ky] = ndgrid(kx, ky);
    n = sqrt(kx.^2 + ky.^2);
    
elseif imDim == 3
    
    [F, kx, ky, kz] = bmImDFT(argIm);
    [kx, ky, kz] = ndgrid(kx, ky, kz);
    n = sqrt(kx.^2 + ky.^2 + kz.^2);
    
end

FK = 1./normpdf(  n, 0, 1/log(enhence_factor)  );

F   = F.*FK;
out = abs(bmImIDF(  F  ));

out = out/mean(out(:))*myMean_0; 

if plus_flag
   out = out - myPlus;  
end

end