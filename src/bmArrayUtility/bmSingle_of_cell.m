% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmSingle_of_cell(arg_cell)

out = cell(size(arg_cell)); 

for i = 1:length(arg_cell(:))
    out{i} = single(arg_cell{i}); 
end

end