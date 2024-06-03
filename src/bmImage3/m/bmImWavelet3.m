% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% We use the function 'dwt3' which performs a single-level 3D discrete 
% wavelet transform. 
%
% We use the wavelet_type 'sym4' by default. 
%
% We use periodic image extension. 

function [cA, cH, cV, cD] = bmImWavelet3(x, n_u, varargin)

wavelet_type = bmVarargin(varargin); 

if isempty(wavelet_type)
    wavelet_type = 'sym4'; % magic
end

n_u = n_u(:)'; 
x = bmBlockReshape(x, n_u); 

[cA, cH, cV, cD] = dwt3(x, wavelet_type, 'mode', 'per'); 

end