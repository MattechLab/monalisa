% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmShanna(x, G, KFC, n_u, fft_lib_sFlag)

% argin_initial -----------------------------------------------------------
if isempty(n_u)
   n_u =  G.N_u; 
end

if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'CUFFT')
   error('zero_filling is not implemented for Shanna_CUFFT. '); return; 
end
if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'FFTW')
   error('zero_filling is not implemented for Shanna_FFTW. '); return; 
end
% END_argin_initial -------------------------------------------------------



if strcmp(fft_lib_sFlag, 'MATLAB')
    y = bmShanna_MATLAB(x, G, KFC, n_u); 
elseif strcmp(fft_lib_sFlag, 'FFTW')
    y = bmShanna_FFTW_omp(x, G, KFC); 
elseif strcmp(fft_lib_sFlag, 'CUFFT')
    y = bmShanna_CUFFT_omp(x, G, KFC); 
end



end
