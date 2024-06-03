% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function imNav = bmMriPhi_fromSI_imNav(     rmsSI, N, nSeg, nshot, ...
                                            ind_shot_min,   ind_shot_max, ...
                                            ind_SI_min,     ind_SI_max, ...
                                            ind_imNav_min, ind_imNav_max, ...
                                            s_reverse_flag)


 
rmsSI           = rmsSI(ind_imNav_min:ind_imNav_max, ind_shot_min:ind_shot_max); 
mySize_1        = size(rmsSI, 1);
mySize_2        = size(rmsSI, 2);
mySize_2_interp = mySize_2*nSeg + 1; 
t_interp        = 1:mySize_2_interp;
t_interpolant   = t_interp(1, 1:nSeg:end); 

rmsSI = cat(  2, rmsSI, rmsSI(:, end-1)  ); 


imNav = zeros(  mySize_1, mySize_2_interp  ); 
for i = 1:mySize_1
   imNav(i, :) = bmInterp1(t_interpolant, rmsSI(i, :), t_interp);  
end
imNav(:, end) = []; 

imNav = imNav - min(imNav(:)); 
imNav = imNav/max(imNav(:)); 


end


