% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% The output format is the lineOfPoint-format i.e. the size 
% is (3, N, numOfLines). 

function [out, varargout] = bmLineList(psi, theta, phi, d, deltaK, dK, N, lineAssym)

myLength = length(psi);
dK_list = dK*ones(1, myLength);
out = zeros(3, N, myLength); 

e3Prime = zeros(3, myLength); 
e2Prime = zeros(3, myLength); 
dVec    = zeros(3, myLength);

e3 = [0 0 1]'; 
e2 = [0 1 0]'; 

if lineAssym == 0
    myShift = 0;
elseif lineAssym == 1
    myShift = 1;
elseif lineAssym == 2
    myShift = -1;
end

for i = 1:myLength
    
    myLine = zeros(3, N);
    myLine(2,:) = d(i);
    myLine(3,:) = (0:dK_list(i):(N-1)*dK_list(i)) - (N-1)/2*dK_list(i) + myShift*dK_list(i)/2 + deltaK(i);
    
    R= bmRotation(psi(i), theta(i), phi(i));
    out(:,:,i) = R*myLine;
    e3Prime(:,i) = R*e3; 
    e2Prime(:,i) = R*e2; 
end
 
dVec(1,:) = d.*e2Prime(1,:); 
dVec(2,:) = d.*e2Prime(2,:); 
dVec(3,:) = d.*e2Prime(3,:); 

varargout{1} = e3Prime; 
varargout{2} = e2Prime; 
varargout{3} = dVec; 

end
