% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myMask = bmDiskMask(argSize, argCenter, argRadius)

argSize = argSize(:)'; 
argSize = argSize(1, 1:2); 

argCenter = argCenter(:)'; 
argCenter = argCenter(1, 1:2); 

myRadius_squared = argRadius^2; 

[x, y] = ndgrid(1:argSize(1, 1), 1:argSize(1, 2));

myMask = (  (x(:) - argCenter(1, 1)).^2   +   (y(:) - argCenter(1, 2)).^2   ) <= myRadius_squared; 
myMask = logical(reshape(myMask, argSize)); 


end

