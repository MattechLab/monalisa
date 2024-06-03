% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmSingle(a)

if iscell(a)
    
    argSize     = size(a);
    out         = cell(argSize); 
    a           = a(:);
    out         = out(:); 
    
    for i = 1:size(a(:), 1)
       out{i} = single(a{i});  
    end
   
    out = reshape(out, argSize); 
    return; 

else
    out = single(a); 
end


end