% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% We use the function 'dwt' which performs a single-level 1D discrete 
% wavelet transform. 
%
% We use the wavelet_type 'sym4' by default. 
%
% We use periodic extension. 

function [cA, cD] = bmImWavelet1(x, n_u, varargin)

wavelet_type = bmVarargin(varargin); 

if isempty(wavelet_type)
    wavelet_type = 'sym4'; % magic
end

n_u = n_u(:)'; 
x = bmBlockReshape(x, n_u); 

[cA, cD] = dwt(x, wavelet_type, 'mode', 'per'); 

cA = cA(:); 
cD = cD(:); 

end