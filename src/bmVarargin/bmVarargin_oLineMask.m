% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function outMask = bmVarargin_oLineMask(inMask, nLine)

if not(isempty(inMask))
   outMask = inMask; 
else
    outMask = true(1, nLine); 
end

end