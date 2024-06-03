% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myNorm = bmTraj_norm(t)

mySize = size(t); 
mySize = mySize(:)'; 
t = bmPointReshape(t); 

myNorm = zeros(1, size(t, 2)); 
for i = 1:mySize(1, 1)
    myNorm = myNorm + t(i, :).^2; 
end
myNorm = sqrt(myNorm); 
myNorm = reshape(myNorm, mySize(1, 2:end)); 

end