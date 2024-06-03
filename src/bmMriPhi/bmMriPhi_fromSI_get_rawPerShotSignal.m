% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function s = bmMriPhi_fromSI_get_rawPerShotSignal(  rmsSI, ...
                                                    ind_SI_min, ...
                                                    ind_SI_max, ...
                                                    s_reverse_flag)

                                            
N = size(rmsSI, 1); 
L = size(rmsSI, 2); 

temp_x  = repmat(bmCol(1:N), [1, L]);
s      = rmsSI(ind_SI_min:ind_SI_max,  :);
temp_x  = temp_x(ind_SI_min:ind_SI_max, :);



s = mean(s, 1);
% s = sum(temp_x.*s, 1)./sum(s, 1);



s = s - mean(s(:));
s = s/std(s(:));
if s_reverse_flag
    s = -s;
end

end