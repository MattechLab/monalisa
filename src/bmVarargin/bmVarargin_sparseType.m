% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmVarargin_sparseType(sparseType)

if isempty(sparseType)
    out = 'bmSparseMat';
else
    out = sparseType; 
end

end