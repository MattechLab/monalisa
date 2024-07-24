% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [C, varargout] = bmCoilSense_nonCart_secondary(y, C, y_ref, C_ref, Gn, Gu, Gut, ve, convCond, display_flag)

% initial -----------------------------------------------------------------

nIterSmooth = 2; % ----------------------------------------------------------- magic number

if not(strcmp(class(y), 'single'))
    error('y must be of class ''single'' .');
    return; 
end
if not(strcmp(class(y_ref), 'single'))
    error('y must be of class ''single'' .');
    return; 
end

N_u     = double(Gn.N_u(:)'); 
dK_u    = double(Gn.d_u(:)');
imDim   = size(N_u(:), 1); 

nCh_array   = size(y, 2); 
C           = C/nCh_array; 
y_ref       = nCh_array*y_ref/bmY_norm(y_ref, ve)*mean(bmCol(bmY_norm(y, ve, false))); 

y           = cat(2, y_ref(:), y);   
C           = cat(2, C_ref(:), bmColReshape(C, N_u)); 

x = bmColReshape(bmNasha(y, Gn, N_u, C), N_u);

if display_flag
    bmImage(bmBlockReshape(x, N_u))
end


nCh         = size(y, 2); 
ve          = bmY_ve_reshape(ve, size(y)); 
KF          = bmKF([],      N_u, N_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam);
KF_conj     = bmKF_conj([], N_u, N_u, dK_u, nCh, Gu.kernel_type, Gu.nWin, Gu.kernelParam); 

myZero      = zeros(prod(N_u(:)), 1); 
% END_initial -------------------------------------------------------------


while convCond.check()
    
    % image iteration
    v = bmShanna(x, Gu, KF.*C, N_u, 'MATLAB') - y;
    w = bmNakatsha(ve.*v, Gut, KF_conj, false, N_u, 'MATLAB');
    
    d = 2*sum(conj(C).*w, 2);
    Ad = bmShanna(d, Gu, KF.*C, N_u, 'MATLAB');
    lambda = real(  Ad(:)' * (ve(:).*v(:))  )/real(  Ad(:)' * (ve(:).*Ad(:))  );
    x = x - lambda*d; 
    
    if display_flag
        bmImage(bmBlockReshape(x, N_u))
    end
    % END image iteration

    
    % coil iteration
    d_C = 2*repmat(conj(x), [1, nCh]).*w;
    d_C(:, 1) = myZero; 
    Ad_C = bmShanna(x, Gu, KF.*d_C, N_u, 'MATLAB');
    lambda_C = real(  Ad_C(:)' * (ve(:).*v(:))  )/real(  Ad_C(:)' * (ve(:).*Ad_C(:))  );
    C = C - lambda_C*d_C; 
    % END coil iteration 
  
    convCond.disp_info('bmCoilSense_nonCart_secondary'); 
end

% final -------------------------------------------------------------------

C = C(:, 2:end); 
nCh = size(C, 2); 
C = bmBlockReshape(C, N_u);
x = bmBlockReshape(x, N_u); 

for i = 1:nCh
    if imDim == 1
        C(:, i) = bmImPseudoDiffusion(C(:, i), nIterSmooth);
    elseif imDim == 2
        C(:, :, i) = bmImPseudoDiffusion(C(:, :, i), nIterSmooth);
    elseif imDim == 3
        C(:, :, :, i) = bmImPseudoDiffusion(C(:, :, :, i), nIterSmooth);
    end
end

C = C*nCh_array; 

if nargout > 1
    varargout{1} = convCond; 
end
if nargout > 2
    varargout{2} = x; 
end
% END_final ---------------------------------------------------------------

end