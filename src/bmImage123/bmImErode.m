% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImErode(argIm, argShiftList)

out = imerode(argIm, bmImShiftList_to_structEl(argShiftList)); 

end