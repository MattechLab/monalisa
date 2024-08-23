function a = bmMIP(y, N_u)
% a = bmMIP(y, N_u)
%
% This function performs a Maximum Intensity Projection (MIP) on the input 
% data.
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
%   y (array): The data for which the MIP should be calculated.
%   N_u (list): The size of the data of one channel in y.
%
% Results:
%   a (array): The MIP for every data point in either block or column 
%    format depending on the format of x (block or other).

% Reshape data to column format
c   = bmColReshape(y, N_u); 

% Calculate MIP of the data by taking the maximum across all channels for 
% each data point
a   = squeeze(max(abs(c), [], 2)); 

% Reshape MIP data into block or column format, depending on x
if bmIsColShape(y, N_u)
    a = bmColReshape(a, N_u); 
    
elseif bmIsBlockShape(y, N_u)
    a = bmBlockReshape(a, N_u);     
end

end