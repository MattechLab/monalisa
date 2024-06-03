% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImLaplaceEquationSolver(imStart, m, nIter, L_th, varargin)

[omp_flag, nBlockPerThread] = bmVarargin(varargin);

m_neg       = not(m); 
out         = imStart;
myCondition = true;

while myCondition
    
    out = bmImLaplaceIterator(out, m, nIter, omp_flag, nBlockPerThread); 
    L   = bmImLaplacian(out);
    
    
    
    L_squared_norm  = sum(abs(    L(m_neg(:))  ).^2);
    im_squared_norm = sum(abs(  out(m_neg(:))  ).^2);
    r = sqrt(L_squared_norm/im_squared_norm);    
    myCondition = (r > L_th);
    
end

end
