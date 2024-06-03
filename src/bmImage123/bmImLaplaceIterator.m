% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImLaplaceIterator(imStart, m, nIter, varargin)

argSize = size(imStart); 

[omp_flag, nBlockPerThread] = bmVarargin(varargin);
if ischar(omp_flag)
    if strcmp(omp_flag, 'omp')
        omp_flag = true;
    else
        omp_flag = false;
    end
end
if isempty(omp_flag)
    omp_flag = false;
end
if isempty(nBlockPerThread)
    nBlockPerThread = int32(max(argSize(:)));
end

[imStart, imDim, imSize, sx, sy, sz] = bmImReshape(imStart);

real_flag = isreal(imStart);

imStart            = single(imStart);
m                  = logical(m);
m_neg              = logical(not(m));
nIter              = int32(nIter);
nBlockPerThread    = int32(nBlockPerThread);
sx                 = int32(sx);
sy                 = int32(sy);
sz                 = int32(sz);





if imDim == 1
    if omp_flag
        if real_flag
            out = bmImLaplaceEquationSolver1_omp_mex(sx, imStart, m, nIter, nBlockPerThread);
        else
            out_real = bmImLaplaceEquationSolver1_omp_mex(sx, real(imStart), m, nIter, nBlockPerThread);
            out_imag = bmImLaplaceEquationSolver1_omp_mex(sx, imag(imStart), m, nIter, nBlockPerThread);
            out = complex(out_real, out_imag);
        end
    else
        if real_flag
            out = bmImLaplaceEquationSolver1_mex(sx, imStart, m, nIter);
        else
            out_real = bmImLaplaceEquationSolver1_mex(sx, real(imStart), m, nIter);
            out_imag = bmImLaplaceEquationSolver1_mex(sx, imag(imStart), m, nIter);
            out = complex(out_real, out_imag);
        end
    end
elseif imDim == 2
    if omp_flag
        if real_flag
            out = bmImLaplaceEquationSolver2_omp_mex(sx, sy, imStart, m, nIter, nBlockPerThread);
        else
            out_real = bmImLaplaceEquationSolver2_omp_mex(sx, sy, real(imStart), m, nIter, nBlockPerThread);
            out_imag = bmImLaplaceEquationSolver2_omp_mex(sx, sy, imag(imStart), m, nIter, nBlockPerThread);
            out = complex(out_real, out_imag);
        end
    else
        if real_flag
            out = bmImLaplaceEquationSolver2_mex(sx, sy, imStart, m, nIter);
        else
            out_real = bmImLaplaceEquationSolver2_mex(sx, sy, real(imStart), m, nIter);
            out_imag = bmImLaplaceEquationSolver2_mex(sx, sy, imag(imStart), m, nIter);
            out = complex(out_real, out_imag);
        end
    end
elseif imDim == 3
    if omp_flag
        if real_flag
            out = bmImLaplaceEquationSolver3_omp_mex(sx, sy, sz, imStart, m, nIter, nBlockPerThread);
        else
            out_real = bmImLaplaceEquationSolver3_omp_mex(sx, sy, sz, real(imStart), m, nIter, nBlockPerThread);
            out_imag = bmImLaplaceEquationSolver3_omp_mex(sx, sy, sz, imag(imStart), m, nIter, nBlockPerThread);
            out = complex(out_real, out_imag);
        end
    else
        if real_flag
            out = bmImLaplaceEquationSolver3_mex(sx, sy, sz, imStart, m, nIter);
        else
            out_real = bmImLaplaceEquationSolver3_mex(sx, sy, sz, real(imStart), m, nIter);
            out_imag = bmImLaplaceEquationSolver3_mex(sx, sy, sz, imag(imStart), m, nIter);
            out = complex(out_real, out_imag);
        end
    end
end

out = reshape(out, argSize); 

end


