% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function outMask = bmVarargin_eLineMask(inMask, nLine)

if not(isempty(inMask))
   outMask = inMask; 
else
    outMask = false(1, nLine); 
end

end