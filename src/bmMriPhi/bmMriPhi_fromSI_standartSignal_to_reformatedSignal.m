% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function s_final = bmMriPhi_fromSI_standartSignal_to_reformatedSignal(  s_filtered, ...
                                                                        nSeg, ...
                                                                        nShot, ...
                                                                        ind_shot_min, ...
                                                                        ind_shot_max, ...
                                                                        varargin    )
                                            
argIm = bmVarargin(varargin); 

L           = size(s_filtered, 2)/2;
s_mid       = s_filtered(:, 1:L);

if ind_shot_min > 1
    nLine_start = (ind_shot_min - 1)*nSeg;
    s_start     = s_mid(:, 1:nLine_start);
    s_start     = flip(s_start, 2);
else
    s_start     = [];
end

if ind_shot_max < nShot
    nLine_end   = (nShot - ind_shot_max)*nSeg;
    s_end       = s_mid(:, end - nLine_end+1:end);
    s_end       = flip(s_end, 2);
else
    s_end = [];
end

s_final = cat(2, s_start, s_mid, s_end);



% plot --------------------------------------------------------------------
if ~isempty(argIm)
    
    N           = size(argIm, 1); 

    figure
    hold on
    imagesc(argIm)
    set(gca, 'YDir', 'normal');
    colormap gray
    
    x_plot = ind_shot_min + (0:L-1)/nSeg;
    plot(x_plot(1:nSeg:L),      ceil(N/2) + ceil(N/8)*s_mid(1:nSeg:L), '.-', 'Markersize', 15)
    
    x_plot = ind_shot_min + [-nLine_start:-1, 0:L-1, L:L+nLine_end-1]/nSeg;
    plot(x_plot(1:nSeg:end),    ceil(N/2) + ceil(N/8)*s_final(1:nSeg:end), '.-')
end
% END_plot ----------------------------------------------------------------



end

