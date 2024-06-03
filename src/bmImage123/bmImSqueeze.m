% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [outIm, imDim, imSize, varargout] = bmImSqueeze(argIm)
 
[outIm, imDim, imSize, s1, s2, s3]  = bmImReshape(squeeze(argIm)); 

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