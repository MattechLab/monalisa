% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmMriPhi_fromSI_plot_signal(   s, ...
                                    	ind_shot_min, ...
                                    	ind_shot_max, ...
                                    	ind_SI_min, ...
                                    	ind_SI_max, ...
                                    	plot_factor) 
        
if ~isempty(s)
    s          = s(:, ind_shot_min:ind_shot_max); 
    s_plot      = s*plot_factor + (ind_SI_min + ind_SI_max)/2;
    ind_plot    = ind_shot_min:ind_shot_max; 
    
    plot(ind_plot, s_plot, 'r.-')
end

end