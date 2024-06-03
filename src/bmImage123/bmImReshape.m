% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [outIm, imDim, imSize, varargout] = bmImReshape(argIm)

outIm = argIm; 
imDim = bmImDim(argIm);

if imDim == 0
   error('The image dimension is 0. '); 
   return; 
end

if imDim == 1
   outIm = outIm(:); 
end
[imDim, imSize, s1, s2, s3] = bmImDim(outIm); 


if nargout > 3
    varargout{1} = s1; 
end
if nargout > 4
    varargout{2} = s2; 
end
if nargout > 5
    varargout{3} = s3; 
end

end