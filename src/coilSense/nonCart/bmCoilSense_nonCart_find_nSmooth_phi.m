% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmCoilSense_nonCart_find_nSmooth_phi(y, Gn, m, nSmooth_phi)

N_u         = double(Gn.N_u(:)');
nPt         = double(Gn.r_size);
nCh         = size(y(:), 1)/nPt;
imDim       = size(N_u(:), 1); 

m           = logical(reshape(m, N_u));
m_rep       = repmat(m(:), [1, nCh]); 
m_neg_rep   = not(m_rep); 

x_ch            = bmColReshape(bmNasha(y, Gn), N_u); 
x_ch(m_neg_rep) = 1; 
x_ch            = bmBlockReshape(x_ch, N_u);

z     = zeros([N_u, nCh], 'single'); 
C_abs = complex(z, z); 
C_phi = complex(z, z); 

for i = 1:nCh
    if imDim == 1
        
        temp_a              = x_ch(:, i);
        temp_im             = bmImPseudoDiffusion_inMask(temp_a, m, nSmooth_phi); 
        C_abs(:, i)         = abs(temp_im);
        C_phi(:, i)         = angle(temp_im);

    elseif imDim == 2
        
        temp_a              = x_ch(:, :, i);
        temp_im             = bmImPseudoDiffusion_inMask(temp_a, m, nSmooth_phi); 
        C_abs(:, :, i)      = abs(temp_im);
        C_phi(:, :, i)      = angle(temp_im);
        
    elseif imDim == 3
        
        temp_a              = x_ch(:, :, :, i);
        temp_im             = bmImPseudoDiffusion_inMask(temp_a, m, nSmooth_phi); 
        C_abs(:, :, :, i)   = abs(temp_im);
        C_phi(:, :, :, i)   = angle(temp_im);
        
    end
end

C_abs = bmBlockReshape(C_abs, N_u); 
C_phi = bmBlockReshape(C_phi, N_u); 


C_abs_im = C_abs; 
C_abs_im = C_abs_im - min(C_abs_im(m(:))); 
C_abs_im = C_abs_im/max(C_abs_im(m(:)))*100; 
C_abs_im = bmColReshape(C_abs_im, N_u); 
C_abs_im(m_neg_rep) = 0;  
C_abs_im = bmBlockReshape(C_abs_im, N_u); 


C_phi_im = C_phi; 
C_phi_im = C_phi_im - min(C_phi_im(m(:))); 
C_phi_im = C_phi_im/max(C_phi_im(m(:)))*100; 
C_phi_im = bmColReshape(C_phi_im, N_u); 
C_phi_im(m_neg_rep) = 0;  
C_phi_im = bmBlockReshape(C_phi_im, N_u);


bmImage(cat(2, C_phi_im, C_abs_im))
clim([0, 100])
if nCh == 1
    bmImage(cat(2, permute(C_phi_im, [3, 1, 2]), permute(C_abs_im, [3, 1, 2])))
    clim([0, 100])
else
    bmImage(cat(2, permute(C_phi_im, [3, 1, 2, 4]), permute(C_abs_im, [3, 1, 2, 4])))
    clim([0, 100])
end

end

