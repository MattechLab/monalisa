% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [  cuda_I_dir, ...
    cuda_L_dir, ...
    fftw_I_dir, ...
    fftw_L_dir] = bmMex_extern_dir(arg_file)

cuda_I_dir = [];
cuda_L_dir = [];
fftw_I_dir = [];
fftw_L_dir = [];

c = bmTextFile2Cell(arg_file); 

for i = 1:numel(c)
   
    if strcmp(c{i}, 'cuda_I_dir')
       cuda_I_dir = c{i+1};  
    end
    if strcmp(c{i}, 'cuda_L_dir')
       cuda_L_dir = c{i+1};  
    end
    if strcmp(c{i}, 'fftw_I_dir')
       fftw_I_dir = c{i+1};  
    end
    if strcmp(c{i}, 'fftw_L_dir')
       fftw_L_dir = c{i+1};  
    end
end


end