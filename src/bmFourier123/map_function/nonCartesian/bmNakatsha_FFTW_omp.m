% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNakatsha_FFTW_omp(y, G, KFC_conj)

% argin_initial -----------------------------------------------------------
N_u     = double(single(G.N_u(:)'));
nPt     = double(G.r_size);
imDim   = size(N_u(:), 1);
nCh     = size(y, 2);

private_check(y, G, KFC_conj, N_u, nCh, nPt);
% END_argin_initial -------------------------------------------------------

if imDim == 1
    [x_real, x_imag] = bmNakatsha1_FFTW_omp_mex(   real(y), imag(y), real(KFC_conj), imag(KFC_conj), int32(N_u), ...
                                    G.r_size, G.r_jump, G.r_nJump, ...
                                    G.m_val, ...
                                    G.l_size, G.l_jump, G.l_nJump);
    x = x_real + 1i*x_imag; 
elseif imDim == 2
    [x_real, x_imag] = bmNakatsha2_FFTW_omp_mex(   real(y), imag(y), real(KFC_conj), imag(KFC_conj), int32(N_u), ...
                                    G.r_size, G.r_jump, G.r_nJump, ...
                                    G.m_val, ...
                                    G.l_size, G.l_jump, G.l_nJump);
    x = x_real + 1i*x_imag; 
elseif imDim == 3
    [x_real, x_imag] = bmNakatsha3_FFTW_omp_mex(   real(y), imag(y), real(KFC_conj), imag(KFC_conj), int32(N_u), ...
                                    G.r_size, G.r_jump, G.r_nJump, ...
                                    G.m_val, ...
                                    G.l_size, G.l_jump, G.l_nJump);
    x = x_real + 1i*x_imag; 
                                
end


end




function private_check(y, G, KFC_conj, N_u, nCh, nPt)

if not(isa(y, 'single'))
    error('The data''y'' must be of class single');
    return;
end

if not(isa(KFC_conj, 'single'))
    error('The matrix ''KFC_conj'' must be of class single');
    return;
end




if not(isequal(size(y), [nPt, nCh]))
    error('The data matrix ''y'' is not in the correct size');
    return;
end


if not(isequal(size(KFC_conj), [prod(N_u(:)), nCh] ))
    error('The matrix ''KFC_conj'' is not in the correct size');
    return;
end



if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
    return;
end

if not(strcmp(G.block_type, 'one_block'))
    error('The block type of G must be ''one_block''. ');
    return;
end

if strcmp(class(G), 'bmSparseMat')
    if not(strcmp(G.type, 'cpp_prepared')) && not(strcmp(G.type, 'l_squeezed_cpp_prepared'))
        error('G is bmSparseMat but is not cpp_prepared. ');
        return;
    end
end

end