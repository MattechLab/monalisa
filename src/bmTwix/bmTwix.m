% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myTwix = bmTwix(argFile)


myTwix = mapVBVD_JH_in_bmToolBox(argFile);
if iscell(myTwix)
    myTwix = myTwix{end};
end


end