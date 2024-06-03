% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImGaussFiltering(argIm, argSigma, blackBorder)

[argIm, imDim, imSize_0] = bmImReshape(argIm); 

blackBorder = blackBorder(:)'; 

if imDim == 2

    bx      = ceil(blackBorder(1, 1));
    by      = ceil(blackBorder(1, 2));

    z1      = zeros(bx, imSize_0(1, 2)); 
    argIm   = cat(1, z1, argIm, z1); 

    z2      = zeros(imSize_0(1, 1)+2*bx, by);
    argIm   = cat(2, z2, argIm, z2); 

elseif imDim == 3

    bx      = ceil(blackBorder(1, 1));
    by      = ceil(blackBorder(1, 2));
    bz      = ceil(blackBorder(1, 3));

    z1      = zeros(bx, imSize_0(1, 2), imSize_0(1, 3)); 
    argIm   = cat(1, z1, argIm, z1); 

    z2      = zeros(imSize_0(1, 1)+2*bx, by, imSize_0(1, 3));
    argIm   = cat(2, z2, argIm, z2);
 
    z3      = zeros(imSize_0(1, 1)+2*bx, imSize_0(1, 2)+2*by, bz);
    argIm   = cat(3, z3, argIm, z3);


end

[argIm, imDim, imSize] = bmImReshape(argIm); 

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

FK = normpdf(n, 0, 1/2/pi/argSigma);
F = F.*FK;
out = real(bmImIDF(F));
out = out/mean(out(:)); 


if imDim == 2
    out = out(bx+1:bx+imSize_0(1, 1), by+1:by+imSize_0(1, 2));
elseif imDim == 3
    out = out(bx+1:bx+imSize_0(1, 1), by+1:by+imSize_0(1, 2), bz+1:bz+imSize_0(1, 3));
end
    
    