% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [y_ref, C_ref] = bmCoilSense_nonCart_ref(y, Gn, m, nSmooth_phi)
% We need to chose the data of one of the body coils, the scope of this
% function is to select one of the body coil data, and estimate the coil
% sensitivity of that body coil.
% y (complex) in col shape (nPt, nCh)
% Gn (Sparse matrix)
% m (_,_),(_,_,_) size of one frame
% nSmooth_phi (1)

L_nIter = 1000; % ----------------------------------------------------------- magic number
L_th    = 1e-4; % ----------------------------------------------------------- magic number

N_u         = double(Gn.N_u(:)');
nPt         = double(Gn.r_size); 
imDim       = size(N_u(:), 1);
nCh         = size(y(:), 1)/nPt; 

m           = logical(reshape(m, N_u));
m_neg       = not(m); 
m_rep       = repmat(m(:), [1, nCh]); 
m_neg_rep   = not(m_rep); 

x_ch            = single(bmColReshape(bmNasha(y, Gn, N_u), N_u)); 
x_ch(m_neg_rep) = 1; 
x_ch            = bmBlockReshape(x_ch, N_u);
myRMS           = bmRMS(x_ch, N_u);


z     = zeros([N_u, nCh], 'single'); 
C     = complex(z, z);

for i = 1:nCh
    if imDim == 1
        
        temp_a              = x_ch(:, i);
        C_abs               = bmImPseudoDiffusion_inMask(  abs(temp_a)./myRMS  , m, 2); 
        
        if not(isempty(nSmooth_phi))
            C_phi           = angle(bmImPseudoDiffusion_inMask(temp_a,    m, nSmooth_phi));
        else
            C_phi           = zeros(size(temp_a)); 
        end
        
        temp_C              = C_abs.*exp(1i*C_phi);
        temp_C(m_neg)       = 0; 
        C(:, i)             = bmImLaplaceEquationSolver(temp_C, m, L_nIter, L_th, 'omp'); 

    elseif imDim == 2
        
        temp_a              = x_ch(:, :, i);
        C_abs               = bmImPseudoDiffusion_inMask(  abs(temp_a)./myRMS  , m, 2); 
        
        if not(isempty(nSmooth_phi))
            C_phi           = angle(bmImPseudoDiffusion_inMask(temp_a,    m, nSmooth_phi));
        else
            C_phi           = zeros(size(temp_a)); 
        end
        
        temp_C              = C_abs.*exp(1i*C_phi); 
        temp_C(m_neg)       = 0; 
        C(:, :, i)          = bmImLaplaceEquationSolver(temp_C, m, L_nIter, L_th, 'omp');  
        
    elseif imDim == 3
        
        temp_a              = x_ch(:, :, :, i);
        C_abs               = bmImPseudoDiffusion_inMask(  abs(temp_a)./myRMS  , m, 2); 

        if not(isempty(nSmooth_phi))
            C_phi           = angle(bmImPseudoDiffusion_inMask(temp_a,    m, nSmooth_phi));
        else
            C_phi           = zeros(size(temp_a)); 
        end
        
        temp_C              = C_abs.*exp(1i*C_phi); 
        temp_C(m_neg)       = 0; 
        C(:, :, :, i)       = bmImLaplaceEquationSolver(temp_C, m, L_nIter, L_th, 'omp'); 

    end
end

x_ch   = bmColReshape(x_ch, N_u); 
C      = bmColReshape(C, N_u); 


% definition of C_ref and y_ref -------------------------------------------
C_ref = C(:, 1); 
y_ref = y(:, 1); 
% END_definition of C_ref and y_ref ---------------------------------------


C_ref = bmBlockReshape(C_ref, N_u);  

end

