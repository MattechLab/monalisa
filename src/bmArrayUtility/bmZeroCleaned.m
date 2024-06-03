% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmZeroCleaned(argA)

out = argA(:); 
out(out == 0) = []; 

end