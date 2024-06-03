% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImOpen(argIm, argShiftList)

out = argIm; 
out = bmImErode(out , argShiftList); 
out = bmImDilate(out, argShiftList); 

end