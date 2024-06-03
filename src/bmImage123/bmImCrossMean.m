% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImCrossMean(argIm)

argSize = size(argIm); 
[argIm, imDim, imSize, sx, sy, sz] = bmImReshape(argIm);

real_flag = isreal(argIm);

argIm     = single(argIm);
sx        = int32(sx);
sy        = int32(sy);
sz        = int32(sz);

if imDim == 1
    error('Case not implemented. '); 
    return; 
    
elseif imDim == 2
    if real_flag
        out = bmImCrossMean2_mex(sx, sy, argIm);
    else
        out_real = bmImCrossMean2_mex(sx, sy, real(argIm));
        out_imag = bmImCrossMean2_mex(sx, sy, imag(argIm));
        out = complex(out_real, out_imag);
    end
elseif imDim == 3
    if real_flag
        out = bmImCrossMean3_mex(sx, sy, sz, argIm);
    else
        out_real = bmImCrossMean3_mex(sx, sy, sz, real(argIm));
        out_imag = bmImCrossMean3_mex(sx, sy, sz, imag(argIm));
        out = complex(out_real, out_imag);
    end
end

out = reshape(out, argSize); 


end