% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This funnction returns the symmetric gradient estimagted with the 
% 2nd level nearest neighbors (i.e. square for 2D and cube for 3D). 

function imGradient = bmImGradient(argIm)

out_x = []; 
out_y = []; 
out_z = []; 

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
        [out_x, out_y] = bmImGradient2_mex(sx, sy, argIm);
    else
        [out_x_real, out_y_real] = bmImGradient2_mex(sx, sy, real(argIm));
        [out_x_imag, out_y_imag] = bmImGradient2_mex(sx, sy, imag(argIm));
        out_x = complex(out_x_real, out_x_imag);
        out_y = complex(out_y_real, out_y_imag);
    end
elseif imDim == 3
    if real_flag
        [out_x, out_y, out_z] = bmImGradient3_mex(sx, sy, sz, argIm);
    else
        [out_x_real, out_y_real, out_z_real] = bmImGradient3_mex(sx, sy, sz, real(argIm));
        [out_x_imag, out_y_imag, out_z_imag] = bmImGradient3_mex(sx, sy, sz, imag(argIm));
        out_x = complex(out_x_real, out_x_imag);
        out_y = complex(out_y_real, out_y_imag);
        out_z = complex(out_z_real, out_z_imag);
    end
end


if imDim == 2
    imGradient = cat(3, out_x, out_y);
elseif imDim == 3
    imGradient = cat(4, out_x, out_y, out_z);
end

end