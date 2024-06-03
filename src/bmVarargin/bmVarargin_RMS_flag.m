% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmVarargin_RMS_flag(myRMS_flag)

if isempty(myRMS_flag)
    out = true;
else
    out = myRMS_flag; 
end

end