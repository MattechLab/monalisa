% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmDoor2Bump(m, jump_width)

myEps = abs(100*eps); 

m = double(m); 
m = m - min(m(:)); 
m = m/max(m(:)); 
m = m(:)'; 

myInd = 1:size(m, 2); 
myInd = myInd(:)'; 

max_mask = (m >= 1-myEps); 
myInd_max = myInd(1, max_mask); 

ind_1 = min(myInd_max(:)); 
ind_2 = max(myInd_max(:)); 

delta_ind = ceil(jump_width); 

ind_3 = ind_1 + delta_ind;  
ind_4 = ind_2 - delta_ind; 

if ind_4 < ind_3
    temp  = ind_3; 
    ind_3 = ind_4; 
    ind_4 = temp; 
end

if (ind_3 <= ind_1) || (ind_4 >= ind_2)
   error('The factor is too large. ');
   return; 
end


bump_ind = ind_3 - ind_1 + 1; 
bump_ind = -bump_ind:bump_ind;
half_bump_width = fix(size(bump_ind, 2)/2)+1; 
myBump = bmBump(bump_ind, abs(bump_ind(1, 1))  ); 
myBump = myBump(1, 1:half_bump_width); 

y = m; 
y(1, ind_1-1:ind_3) = myBump;
y(1, ind_4:ind_2+1) = flip(myBump, 2); 

end