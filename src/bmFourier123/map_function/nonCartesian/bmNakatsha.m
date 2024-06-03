% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNakatsha(y, G, KFC_conj, C_flag, n_u, fft_lib_sFlag)

% argin_initial -----------------------------------------------------------
if isempty(n_u)
   n_u = G.N_u;  
end

if not(C_flag) & strcmp(fft_lib_sFlag, 'FFTW')
    error(' ''C_flag'' must be ''true'' for the FFTW version of bmNakatsha. '); return;
end
if not(C_flag) & strcmp(fft_lib_sFlag, 'CUFFT')
    error(' ''C_flag'' must be ''true'' for the CUFFT version of bmNakatsha. '); return;
end
if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'CUFFT')
   error('zero_filling is not implemented for Shanna_CUFFT. '); return; 
end
if ~isequal(G.N_u, n_u) & strcmp(fft_lib_sFlag, 'FFTW')
   error('zero_filling is not implemented for Shanna_FFTW. '); return; 
end
% END_argin_initial -------------------------------------------------------

if strcmp(fft_lib_sFlag, 'MATLAB')
    x = bmNakatsha_MATLAB(y, G, KFC_conj, C_flag, n_u);
elseif strcmp(fft_lib_sFlag, 'FFTW') 
    x = bmNakatsha_FFTW_omp(y, G, KFC_conj);
elseif strcmp(fft_lib_sFlag, 'CUFFT')
    x = bmNakatsha_CUFFT_omp(y, G, KFC_conj); 
end

end
