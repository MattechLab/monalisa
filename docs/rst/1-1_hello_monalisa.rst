==============
Hello Monalisa
==============

Hi there, it is your first time here, don't forget to leave us a star if you find this useful.
Our code can be found here : https://github.com/MattechLab/monalisa. 

Monalisa is a Matlab/C++ MRI reconstructions toolbox for 2 or 3 spatial dimensions with 0 or 1 or 2 non-spatial dimensions. 
You can chose your reconstruction function depending if you want temporal or spatial regularization in the objective functions of the reconstruction problem.  
In the case of dynamic imaging, the number of datalines per bin can be different in each bin. We encourage you to write your own reconstructions
by modifiyng our functions. 

In the `demo` directory of Monalisa, we prepared some minimal example scripts with some prepared data
that you can directly give as argument to our reconstruction functions 
as soon as the compilation step is done (see next section): 

    - Find in the `static_recon_calls_script <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/static_recon_calls_script.m>`_  some test for *static reconstruction*. 
    - Use the `chain_recon_calls_script     <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/chain_recon_calls_script.m>`_ to test *chain reconstructions* (multiple frames with one non-spatial dimension). 
    - The `sheet_recon_calls_script <https://github.com/MattechLab/monalisa/blob/main/demo/script_demo/script_recon_calls/sheet_recon_calls_script.m>`_ performs the tests for *sheet reconstructions* (multiple frames with two non-spatial dimension). 

Use it to test rapidely our reconstruction framework.  
Find `in that course <https://drive.google.com/file/d/12z9JCFhwBJhDW4_3Uy4bhSXCnvPod0os/view?pli=1>`_ the mathematics behind our implementations, with references to the litterature. 

If you are here, you are probably considering our framework for image reconstruction. 
Please be aware that you need a coil sensitivity estimation to run our iterative reconstructions. You can estimate the 
coil sensitivities either with your own method, or with our method (see documentation). But the second alternative makes use of some 
prescan data that you have either to acquire yourself, or that you may found in your raw-data file.     

