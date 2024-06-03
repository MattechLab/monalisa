% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmShanna_CUFFT_omp(x, G, KFC)

% argin_initial -----------------------------------------------------------
N_u         = double(single(G.N_u(:)'));
imDim       = size(N_u(:), 1);
nCh         = size(KFC, 2);
private_check(x, G, KFC, N_u, nCh);
% END_argin_initial -------------------------------------------------------

if imDim == 1
    [y_real, y_imag] = bmShanna1_CUFFT_omp_mex( real(x), imag(x), real(KFC), imag(KFC), int32(N_u), ...
                                G.r_size, G.r_jump, G.r_nJump, ...
                                G.m_val, ...
                                G.l_size, G.l_jump, G.l_nJump);
    y = y_real + 1i*y_imag;
elseif imDim == 2
    [y_real, y_imag] = bmShanna2_CUFFT_omp_mex( real(x), imag(x), real(KFC), imag(KFC), int32(N_u), ...
                                G.r_size, G.r_jump, G.r_nJump, ...
                                G.m_val, ...
                                G.l_size, G.l_jump, G.l_nJump);
    y = y_real + 1i*y_imag;
                            
elseif imDim == 3
    [y_real, y_imag] = bmShanna3_CUFFT_omp_mex( real(x), imag(x), real(KFC), imag(KFC), int32(N_u), ...
                                G.r_size, G.r_jump, G.r_nJump, ...
                                G.m_val, ...
                                G.l_size, G.l_jump, G.l_nJump);
    y = y_real + 1i*y_imag;
    
end

end







function private_check(x, G, KFC, N_u, nCh)

if not(isa(x, 'single'))
    error('The data''x'' must be of class single');
    return;
end

if not(isa(KFC, 'single'))
    error('The matrix ''KFC'' must be of class single');
    return;
end



if not(size(x, 1) == prod(N_u(:)))
    error('The data matrix ''x'' is not in the correct size');
    return;
end


if not(isequal(size(KFC), [prod(N_u(:)), nCh] ))
    error('The matrix ''K'' is probably not in the correct size');
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