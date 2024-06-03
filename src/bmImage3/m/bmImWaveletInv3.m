% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% We use the function 'idwt2' which performs an inverse single-level 2D 
% discrete wavelet transform. 
%
% We use the wavelet_type 'sym4' by default. 
%
% We use periodic image extension. 

function x = bmImWaveletInv2(cA, cH, cV, cD, n_u, varargin)

wavelet_type = bmVarargin(varargin); 

if isempty(wavelet_type)
    wavelet_type = 'sym4'; % magic
end

x = idwt2(cA, cH, cV, cD, wavelet_type, 'mode', 'per'); 
x = bmBlockReshape(x, n_u); 

end