% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function p_out = bmLengthParamPath(p, length_between_neighbors)

nPt         = size(p, 2); 
L           = length_between_neighbors; 

t           = linspace(0, 1, nPt); 
tq          = linspace(0, 1, nPt*1000); % --------------------------------------------- magic_number
interp_x    = interpn(t, p(1, :), tq, 'pchip'); 
interp_y    = interpn(t, p(2, :), tq, 'pchip');
interp_z    = interpn(t, p(3, :), tq, 'pchip'); 

p_interp    = cat(1, interp_x, interp_y, interp_z);
nPt_interp  = size(p_interp, 2); 

L_curr  = 0; 
p_out   = p_interp(:, 1); 
p1      = p_interp(:, 1); 

for i = 2:nPt_interp
    
    p2 = p_interp(:, i); 
    L_curr = L_curr + norm(p2 - p1); 
    
    if L_curr >= L
        p1 = (p1 + p2)/2;
        p_out = cat(2, p_out, p1(:));
        L_curr = 0;
    else
            p1 = p2; 
    end
    
end

if ~isequal(p_out(:, end), p(:, end))
   p_out = cat(2, p_out, p(:, end)); 
end

end