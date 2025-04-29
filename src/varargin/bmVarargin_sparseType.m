function out = bmVarargin_sparseType(sparseType)
% out = bmVarargin_sparseType(sparseType)
%
% This function returns the default sparse type if sparseType is empty.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters;
%   sparseType (char): Char containing the sparse type, default value is
%   'bmSparseMat'.
%
% Returns:
%   out (char): Contains given sparse type or default value if empty.

% Return sparseType if given, return bmSparseMat if empty.
if isempty(sparseType)
    out = 'bmSparseMat';
else
    out = sparseType; 
end

end