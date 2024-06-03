% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmMitosius_load(mitosius_dir, arg_name, varargin)

temp_load           = load([mitosius_dir, '/mitosius_size']); 
in_mitosius_size    = bmCol(temp_load.mitosius_size)';  
mitosius_ndims      = size(in_mitosius_size(:), 1); 
out_mitosius_size   = zeros(1, mitosius_ndims); 




% defining_edge_list_and_out_mitosius_size --------------------------------
if isempty(varargin)    
    L = mitosius_ndims; 
    edge_list = cell(L, 1); 
    for i = 1:L
        temp_edge = 1:in_mitosius_size(1, i);
        edge_list{i, 1} = temp_edge(:)';
        out_mitosius_size(1, i) = size(temp_edge(:), 1); 
    end
else
    if length(varargin) ~= mitosius_ndims
        error('The number of edges not compatible with mitosius_ndims. '); 
        return; 
    end
    
    L = mitosius_ndims; 
    edge_list = cell(L, 1); 
    for i = 1:L
        temp_edge = varargin{i}; 
        
        if ischar(temp_edge)
            if strcmp(temp_edge, 'all')
               temp_edge = 1:in_mitosius_size(1, i);
            else
                error('Wrong input arguments. ');
                return; 
            end
        elseif isnumeric(temp_edge)
            temp_edge = varargin{i}; 
        end
        
        temp_edge = bmCol(temp_edge)'; 
        edge_list{i, 1} = temp_edge;
        out_mitosius_size(1, i) = size(temp_edge(:), 1); 
    end
end
% END_defining_edge_list_and_out_mitosius_size ----------------------------





out_mitosius_length = prod(out_mitosius_size(:)); 
out = cell(out_mitosius_length, 1); 
for i = 1:out_mitosius_length
    
    outMultiIndex   = bmIndex2MultiIndex(i, out_mitosius_size); 
    inMultiIndex    = zeros(1, mitosius_ndims); 
    for j = 1:mitosius_ndims
       inMultiIndex(1, j) = edge_list{j, 1}(1, outMultiIndex(1, j));  
    end
    
    num_id = [];
    for j = 1:mitosius_ndims
        num_id = cat(2, num_id, '_', num2str(inMultiIndex(1, j))  );
    end
    
    curr_file = [mitosius_dir, '/cell', num_id, '/' , arg_name, '.mat'];
    temp_load = load(curr_file);
    temp_name = fieldnames(temp_load);
    out{i, 1} = temp_load.(temp_name{1});
    
end

out = squeeze(reshape(out, out_mitosius_size)); 

end

