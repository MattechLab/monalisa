% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function m = bmMriPhi_magnitude_to_mask(s, ...
                                        nMask, ...
                                        nSeg, ...
                                        nShot, ...
                                        ind_shot_min, ...
                                        ind_shot_max)

nSignal = size(s, 1); 

for i = 1:nSignal
    s_min   = min(  s(i, :)  );
    s(i, :) = s(i, :) - s_min;
    
    s_max   = max(  s(i, :)  );
    s(i, :) = s(i, :)/s_max;
end

nLine       = size(s, 2); 
n           = ceil(nLine/nMask); 
ind_line    = 1:nLine; 

m = false(nMask, nLine, nSignal);
for j = 1:nSignal
    
    [s_sorted, myPerm]  = sort(s(j, :));
    ind_sorted          = ind_line(myPerm);
    [~, myInvPerm]      = sort(ind_sorted);

    for i = 1:nMask
        temp_mask = false(1, nLine);
        
        ind_1 = (i-1)*n+1;
        ind_2 = (i-1)*n+n;
        ind_2 = min(ind_2, nLine  );
        
        temp_mask(1, ind_1:ind_2) = true;
        m(i, :, j) = temp_mask(1, myInvPerm);
    end
    
    if ind_shot_min > 1
        nLine_start = (ind_shot_min - 1)*nSeg;
        m(:, 1:nLine_start, j) = false;
    end

end


% plot --------------------------------------------------------------------
for j = 1:nSignal
    figure
    hold on
    plot(s(j, :), '.-')
    plot_ind = 1:size(s, 2);
    for i = 1:nMask
        plot(plot_ind(1, m(i, :, j)), s(j, m(i, :, j)), '.')
    end    
end
% END_plot ----------------------------------------------------------------

m = sum(double(m), 3); 
m = logical(m); 


end