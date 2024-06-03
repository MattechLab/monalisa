% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function return a list of (short) names, off all files and
% directories. 

% varargin{1} must be true for reccursive. 

function out = bmNameList(argDir, varargin)

    if not(bmCheckDir(argDir, false))  
        out = []; 
        return;
    end; 
    
    myList = dir(argDir); 
    myList = myList(3:end);
    
    out = cell(length(myList),1); 
    for i = 1:length(myList)
        out{i} = myList(i).name; 
    end
    
    N = size(out(:), 1); 
    
    if length(varargin) > 0
       if varargin{1}
           for i = 1:N
                out = cat(1, out, bmNameList([argDir, '/', out{i}], true)); 
           end
       end
    end
    

end