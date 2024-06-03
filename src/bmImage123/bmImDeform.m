% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x_out = bmImDeform(Tu, x, n_u, K)

if isempty(Tu)
   x_out = x; 
   return; 
end

imDim   = size(n_u(:), 1); 
x_out   = bmColReshape(x, n_u); 

x_out   = bmSparseMat_vec(Tu, x_out, 'omp', 'complex', false); 

if ~isempty(K)
    K       = bmColReshape(K, n_u);
    Fx = [];
    if imDim == 1
        Fx = bmDFT1(x_out, n_u, 1./n_u);
    elseif imDim == 2
        Fx = bmDFT2(x_out, n_u, 1./n_u);
    elseif imDim == 3
        Fx = bmDFT3(x_out, n_u, 1./n_u);
    end
    Fx = Fx.*K;
    if imDim == 1
        x_out = bmIDF1(Fx, n_u, 1./n_u);
    elseif imDim == 2
        x_out = bmIDF2(Fx, n_u, 1./n_u);
    elseif imDim == 3
        x_out = bmIDF3(Fx, n_u, 1./n_u);
    end 
end

if bmIsBlockShape(x, n_u)
    x_out = bmBlockReshape(x_out, n_u); 
end

end