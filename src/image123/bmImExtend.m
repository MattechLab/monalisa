% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function outIm = bmImExtend(argIm, nPix)

if nPix == 0
   outIm = argIm; 
   return; 
end

[sqIm, imDim, imSize, s1, s2, s3] = bmImSqueeze(argIm); 


if imDim == 1
    outIm = zeros(s1 + 2*nPix, 1);
    outIm(nPix+1 : nPix + s1, 1) = sqIm;
end

if imDim == 2
    outIm = zeros(imSize + 2*nPix);
    outIm(nPix+1 : nPix+s1, nPix+1 : nPix+s2) = sqIm;
end


if imDim == 3
    outIm = zeros(imSize + 2*nPix);
    outIm(nPix+1 : nPix+s1, nPix+1 : nPix+s2, nPix+1 : nPix+s3) = sqIm;
end


end
