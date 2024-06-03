% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function x_out = bmImDeformT(Tut, x, n_u, K)

if isempty(Tut)
    x_out = x; 
    return; 
end

x_out   = bmColReshape(x, n_u); 
imDim   = size(n_u(:), 1); 

if ~isempty(K)
    K       = bmColReshape(K, n_u);
    Fx = [];
    if imDim == 1
        Fx = bmIDF1_conjTrans(x_out, n_u, 1./n_u);
    elseif imDim == 2
        Fx = bmIDF2_conjTrans(x_out, n_u, 1./n_u);
    elseif imDim == 3
        Fx = bmIDF3_conjTrans(x_out, n_u, 1./n_u);
    end
    Fx = Fx.*K;
    if imDim == 1
        x_out = bmDFT1_conjTrans(Fx, n_u, 1./n_u);
    elseif imDim == 2
        x_out = bmDFT2_conjTrans(Fx, n_u, 1./n_u);
    elseif imDim == 3
        x_out = bmDFT3_conjTrans(Fx, n_u, 1./n_u);
    end
end

x_out = bmSparseMat_vec(Tut, x_out, 'omp', 'complex', false); 

if bmIsBlockShape(x, n_u)
    x_out = bmBlockReshape(x_out, n_u); 
end

end