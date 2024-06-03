% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImClose(argIm, argShiftList)

out = argIm; 
out = bmImDilate(out, argShiftList); 
out = bmImErode( out, argShiftList); 

end