% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmAffineSolve(y, f, x)

[x, myPerm] = sort(x);
f = f(myPerm);

if y >= f(end)
    
    mySlope = (f(end) - f(end-1))/(x(end) - x(end-1));
    myOffset = f(end) - mySlope*x(end);
    
elseif y <= f(1)
    
    mySlope = (f(2) - f(1))/(x(2) - x(1));
    myOffset = f(1) - mySlope*x(1);
    
else
    
    myDiff = y - f;
    myDiff(myDiff <= 0) = [];
    myIndex = length(myDiff);
    
    mySlope = (f(myIndex+1) - f(myIndex))/(x(myIndex+1) - x(myIndex));
    myOffset = f(myIndex) - mySlope*x(myIndex);
    
    
    
end

out = (y - myOffset)/mySlope; 


end