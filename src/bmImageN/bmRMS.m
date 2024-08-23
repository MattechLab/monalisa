function a = bmRMS(x, N_u)
% a = bmRMS(x, N_u)
%
% This function calculates the root mean square (RMS) value for each data
% point across all channels.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   x (array): The data for which the RMS should be calculated.
%   N_u (list): The size of the data of one channel in x.
%
% Results:
%   a (array): The RMS for every data point in either block or column 
%    format depending on the format of x (block or other).


% Reshape data to column format
c   = bmColReshape(x, N_u); 

% Calculate RMS for each data point across the channels (rows)
a   = squeeze(sqrt(mean(abs(c).^2, 2))); 

% Reshape RMS data into block or column format, depending on x
if bmIsColShape(x, N_u) 
    a = bmColReshape(a, N_u); 
    
elseif bmIsBlockShape(x, N_u)
    a = bmBlockReshape(a, N_u);     
end

end