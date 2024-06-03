% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x = bmNasha_partialCartesian(y, ind_u, C, N_u, n_u, dK_u)

% argin_initial -----------------------------------------------------------

if isempty(n_u)
   n_u = N_u;  
end

y       = single(y);  
N_u     = double(   int32(N_u(:)')     );
n_u     = double(   int32(n_u(:)')       );
dK_u    = double(   single(dK_u(:)')     );
imDim   = size(N_u(:), 1);
nPt     = size(y, 1);
nCh     = size(y, 2);

C_flag = false;
if not(isempty(C))
    C_flag = true;
    C = single(bmColReshape(C, n_u));
end

private_check(y, C, N_u, n_u, nPt, nCh)

% END_argin_initial -------------------------------------------------------

% gridding
x = bmGut_partialCartesian(y, ind_u, N_u); 

% fft
x = bmBlockReshape(x, N_u); 

if imDim == 1
    x = bmIDF1(x, single(N_u), single(dK_u) );
elseif imDim == 2
    x = bmIDF2(x, single(N_u), single(dK_u) );
elseif imDim == 3
    x = bmIDF3(x, single(N_u), single(dK_u) );
end

% eventual croping
if ~isequal(N_u, n_u)
   x = bmImCrope(x, N_u, n_u);  
end

% eventual coil_combine
if not(isempty(C))
    C = bmBlockReshape(C, n_u);
    x = bmCoilSense_pinv(C, x, n_u);
end


end



function private_check(y, C, N_u, n_u, nPt, nCh)

if not(isa(y, 'single'))
    error('The data''y'' must be of class single. ');
    return; 
end






if not(isempty(C))
    if not(isa(C, 'single'))
        error('The data''C'' must be of class single. ');
        return;
    end
end


if not(isequal( size(y), [nPt, nCh] ))
    error('The data matrix ''y'' is not in the correct size. ');
    return;
end






if not(isempty(C))
    if not(isequal( size(C), [prod(N_u(:)), nCh] ))
        error('The matrix ''C'' has not the correct size. ');
        return;
    end
end



if sum(mod(N_u(:), 2)) > 0
    error('N_u must have all components even for the Fourier transform. ');
    return;
end




end