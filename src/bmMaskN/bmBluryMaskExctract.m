% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [out, outSum] = bmBluryMaskExctract(argBluryMask ,argArray);

argBluryMask = argBluryMask(:)';
argArray     = argArray(:)';
argArray     = argArray.*argBluryMask ;


myMask = logical(argBluryMask);
out = argArray(myMask);
outSum = sum(argBluryMask); 

end