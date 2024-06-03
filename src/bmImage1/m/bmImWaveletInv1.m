% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% We use the function 'idwt' which performs an inverse single-level 1D 
% discrete wavelet transform. 
%
% We use the wavelet_type 'sym4' by default. 
%
% We use periodic extension. 

function x = bmImWaveletInv1(cA, cD, n_u, varargin)

wavelet_type = bmVarargin(varargin); 

if isempty(wavelet_type)
    wavelet_type = 'sym4'; % magic
end

cA = cA(:); 
cD = cD(:); 

x = idwt(cA, cD, wavelet_type, 'mode', 'per'); 
x = bmBlockReshape(x, n_u); 

end