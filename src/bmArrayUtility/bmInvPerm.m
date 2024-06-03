% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myPerm_inv = bmInvPerm(myPerm)

myPerm  = myPerm(:)'; 
N       = size(myPerm(:), 1); 
myList  = [1:N]; 
myList  = myList(myPerm); 
[~, myPerm_inv] = sort(myList); 

end