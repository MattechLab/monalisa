% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmImage(argImage, varargin)

argParam = bmVarargin(varargin); 
uiwait_flag = false; 

if iscell(argImage)
   argImage = squeeze(bmCell2Array(argImage)); 
end
if not(isreal(argImage))
   argImage = abs(argImage);  
end
if islogical(argImage)
    argImage = double(argImage); 
end


if ndims(argImage) == 2
    outParam = bmImage2(argImage, argParam, uiwait_flag);
elseif ndims(argImage) == 3
    outParam = bmImage3(argImage, argParam, uiwait_flag);
elseif ndims(argImage) == 4
    outParam = bmImage4(argImage, argParam, uiwait_flag);
elseif ndims(argImage) == 5
    outParam = bmImage5(argImage, argParam, uiwait_flag);
end

if nargout > 0
    varargout{1} = outParam; 
end

end