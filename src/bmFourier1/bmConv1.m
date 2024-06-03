% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function s = bmConv1(f, h, dx)

f = f(:).';
h = h(:).'; 

N = size(f(:), 1); 
s = zeros(1, N); 


for n = -N/2:N/2-1
    
    temp_sum = 0; 
    
    for k = -N/2:N/2-1
        
        ind_2 = k + N/2 + 1; 
        ind_3 = private_mod(n-k, N) + N/2 + 1; 
        
        temp_sum = temp_sum + dx*f(1, ind_2)*h(1, ind_3); 
        
    end
    
    s(n + N/2 + 1) = temp_sum; 
    
end



end


function myMod = private_mod(n, N)
    myMod = mod(n + N/2, N) - N/2; 
end