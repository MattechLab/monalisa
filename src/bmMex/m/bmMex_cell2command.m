% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [myCommand, myCommand_flag] = bmMex_cell2command( c, cuda_I_dir, cuda_L_dir, fftw_I_dir, fftw_L_dir)

myCommand = []; 
myCommand_flag = true; 

c = c(:);

% deleting '...' at end of lines
for i = 1:numel(c)
    if length(c{i}) > 3
        if strcmp(c{i}(end-2:end), '...')
            c{i} = c{i}(1:end-3); 
        end
    end
end

% deleting white spaces at start of lines
for i = 1:numel(c)
    if length(c{i}) > 0
        while strcmp(c{i}(1), ' ')
           c{i} = c{i}(2:end);  
        end
    end
end

% subsitution
for i = 1:numel(c)
    
    if strcmp(c{i}, 'cuda_I_dir')
        
        if isempty(cuda_I_dir)
            myCommand_flag = false; 
            myCommand = []; 
           return;  
        end    
        c{i} = ['-I"', cuda_I_dir, '"'];
    end
    
    if strcmp(c{i}, 'cuda_L_dir')
        if isempty(cuda_L_dir)
            myCommand_flag = false; 
            myCommand = []; 
           return;  
        end
        c{i} = ['-L"', cuda_L_dir, '"'];
    end
    
    if strcmp(c{i}, 'fftw_I_dir')
        if isempty(fftw_I_dir)
            myCommand_flag = false; 
            myCommand = []; 
           return;  
        end
        c{i} = ['-I"', fftw_I_dir, '"'];
    end
    
    if strcmp(c{i}, 'fftw_L_dir')
        if isempty(fftw_L_dir)
            myCommand_flag = false; 
            myCommand = []; 
           return;  
        end
        c{i} = ['-L"', fftw_L_dir, '"'];
    end
    
end


myCommand = []; 
for i = 1:numel(c)
   myCommand = [myCommand, ' ', c{i}];  
   if c{i+1} == -1
      break;  
   end
end


end