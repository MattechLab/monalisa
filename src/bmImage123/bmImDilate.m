% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImDilate(argIm, argShiftList)

out = imdilate(argIm, bmImShiftList_to_structEl(argShiftList)); 

end