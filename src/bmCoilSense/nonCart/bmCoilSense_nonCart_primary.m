% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function C = bmCoilSense_nonCart_primary(y, y_ref, C_ref, Gn, ve, m)

nIter_smooth = 2; % ----------------------------------------------------------- magic number
L_nIter = 1000; % ------------------------------------------------------------- magic number
L_th = 1e-4; % ---------------------------------------------------------------- magic number

N_u         = double(Gn.N_u(:)');
nPt         = double(Gn.r_size);
imDim       = size(N_u(:), 1);  
nCh         = size(y(:), 1)/nPt;

nCh_array   = size(y, 2);  
y_ref       = nCh_array*y_ref/bmY_norm(y_ref, ve)*mean(bmCol(bmY_norm(y, ve, false))); 

x_ref       = bmBlockReshape(bmNasha(y_ref, Gn, N_u), N_u);
x           = bmBlockReshape(bmNasha(y, Gn, N_u),     N_u); 



m           = logical(bmBlockReshape(m, N_u)); 
m_neg       = not(m); 

anat_ref    = x_ref./C_ref; 
anat_ref(m_neg) = 1; 


z = zeros([N_u, nCh], 'single'); 
C = complex(z, z); 


for i = 1:nCh
    
    i
    
    if imDim == 1
        temp_im = x(:, i); 
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat_ref, m, nIter_smooth); 
        temp_im(m_neg) = 0; 
        C(:, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');
        
    elseif imDim == 2
        temp_im = x(:, :, i);  
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat_ref, m, nIter_smooth);
        temp_im(m_neg) = 0; 
        C(:, :, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');

    elseif imDim == 3
        temp_im = x(:, :, :, i);  
        temp_im = bmImPseudoDiffusion_inMask(temp_im./anat_ref, m, nIter_smooth);
        temp_im(m_neg) = 0;
        C(:, :, :, i) = bmImLaplaceEquationSolver(temp_im, m, L_nIter, L_th, 'omp');
        
    end
end

C = C*nCh_array; 
C = bmBlockReshape(C, N_u); 

end