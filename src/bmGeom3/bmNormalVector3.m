% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [ey, varargout] = bmNormalVector3(ez)

ez = ez(:); 
ez = ez/sqrt(ez(1)^2 + ez(2)^2 + ez(3)^2); 

[ey, myPerm]    = sort(ez); 
[~ , myInvPerm] = sort(myPerm); 


temp  = ey(3); 
ey(3) = ey(2); 
ey(2) = -temp; 
ey(1) = 0; 
ey = ey/sqrt(ey(1)^2 + ey(2)^2 + ey(3)^2); 
ey = ey(myInvPerm); 
ey = ey(:); 

ex = cross(ey, ez); 
ex = ex(:); 

if nargout > 1
    varargout{1} = ex; 
end



end