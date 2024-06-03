% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% argTh is the threshold, in pixel units, used to hard threshold the
% deformField v. 
%
% The deformField v must be chanel-last and therefore blockReshapable. 
%
% n_u is the imageSize of the deformField. 


function w = bmImDeformField_hardThresholding3(v, n_u, argTh)

myEps = 1e-4; % ------------------------------------------------------------- magic_number

if argTh <= myEps
   error(['The input threshold is smaller than the chosen machine epsilon.', ... 
          'It does not make sense. ']); 
   return; 
end

argSize = size(v); 

v = bmBlockReshape(v, n_u); 

v_norm              = sqrt(  v(:, :, :, 1).^2 + v(:, :, :, 2).^2 + v(:, :, :, 3).^2  ); 

m                   = (v_norm > argTh);  
m                   = repmat(m,         [1, 1, 1, 3]);

eps_mask            = (v_norm <= myEps); 
v_norm(eps_mask)    = 1; 


v_norm              = repmat(v_norm,    [1, 1, 1, 3]); 
v_normalized        = argTh*v./v_norm;

m_neg               = ~m; 

w                   = v.*m_neg + v_normalized.*m; 

w                   = reshape(w, argSize); 

end