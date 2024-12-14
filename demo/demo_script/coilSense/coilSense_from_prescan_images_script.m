
%% param initial

n_u             = [64, 128]; 
display_flag    = true; 


%% mask
x_min           = []; 
x_max           = [];

y_min           = []; 
y_max           = [];

z_min           = []; 
z_max           = [];

th_RMS          = 19; 
th_MIP          = 17; 

close_size      = []; 
open_size       = []; 

m = bmCoilSense_prescan_mask(   prescan_body,  n_u, ... 
                                x_min,  x_max, ... 
                                y_min,  y_max, ... 
                                z_min,  z_max, ... 
                                th_RMS, th_MIP, ... 
                                close_size, ... 
                                open_size, ... 
                                display_flag);

%% C

C   = bmCoilSense_prescan_coilSense(prescan_body, prescan_surface, m, n_u); 
