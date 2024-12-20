==============
Hello Monalisa
==============

Hi there, it is your first time here, don't forget to leave us a star if you find this useful.

Monalisa is a Matlab/C++ MRI reconstructions toolbox for 2 or 3 spatial dimensions with 0 or 1 or 2 temporal dimensions. 
You can chose your reconstruction function depending if you want temporal or spatial regularization in the objective functions of the reconstruction problem.  
In the case of dynamic imaging, the number of datalines per bin can be different in each bin. 

We prepared some minimal example scripts with some prepared data
that you can directly give as argument to our reconstruction functions 
as soon as the compilation step is done (see next section). 
Find `here <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/static_recon_calls_script.m>`__  a script to test static reconstruction. 
Another `here <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/chain_recon_calls_script.m>`__ to test chain reconstructions (multiple frames with one non-spatial dimension). 
And another `here <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/sheet_recon_calls_script.m>`__ to test sheet reconstructions (multiple frames with two non-spatial dimension). 
Use it to test rapidely our reconstruction framework.

If you are here, you are probably considering our framework for image reconstruction. 
Please be aware that you need a coil sensitivity estimation to run our iterative reconstructions. You can estimate the 
coil sensitivities either with your own method, or with our method (see documentation). But the second alternative makes use of some 
prescan data that you have either to acquire yourself, or that you may found in your raw-data file.     
