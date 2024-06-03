% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function mySquaredNorm = bmTraj_squaredNorm(t)

mySize = size(t); 
mySize = mySize(:)'; 
t = bmPointReshape(t); 


mySquaredNorm = zeros(1, size(t, 2)); 
for i = 1:mySize(1, 1)
    mySquaredNorm = mySquaredNorm + t(i, :).^2; 
end

mySquaredNorm = reshape(mySquaredNorm, [1, mySize(1, 2:end)]); 

end