% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% varargin contains the edges of the sub_mitosius. 

function bmMitosius_save(mitosius_dir, file_name, var_name, arg_var, varargin)

arg_var = arg_var(:); 

temp_load           = load([mitosius_dir, '/mitosius_size']); 
mitosius_size       = bmCol(temp_load.mitosius_size)';  
mitosius_ndims      = size(mitosius_size(:), 1); 
mitosius_length     = prod(mitosius_size(:)); 

sub_mitosius_size   = zeros(1, mitosius_ndims); 

% defining_edge_list_and_out_mitosius_size --------------------------------
if isempty(varargin)    
    L = mitosius_ndims; 
    edge_list = cell(L, 1); 
    for i = 1:L
        temp_edge = 1:in_mitosius_size(1, i);
        edge_list{i, 1} = temp_edge(:)';
        sub_mitosius_size(1, i) = size(temp_edge(:), 1); 
    end
else
    if length(varargin) ~= mitosius_ndims
        error('The number of edges not compatible with mitosius_ndims. '); 
        return; 
    end
    
    L = mitosius_ndims; 
    edge_list = cell(L, 1); 
    for i = 1:L
        temp_edge = bmCol(varargin{i})'; 
        edge_list{i, 1} = temp_edge;
        sub_mitosius_size(1, i) = size(temp_edge(:), 1); 
    end
end
% END_defining_edge_list_and_out_mitosius_size ----------------------------


sub_mitosius_length = prod(sub_mitosius_size(:)); 
for i = 1:sub_mitosius_length 

    subMultiIndex   = bmIndex2MultiIndex(i, sub_mitosius_size); 
    multiIndex      = zeros(1, mitosius_ndims); 
    for j = 1:mitosius_ndims
       multiIndex(1, j) = edge_list{j, 1}(1, subMultiIndex(1, j));  
    end

    
    num_id = [];
    for j = 1:mitosius_ndims
        num_id = cat(2, num_id, '_', num2str(multiIndex(1, j))  );
    end
    
    curr_file   = [mitosius_dir, '/cell', num_id, '/', file_name]; 
    curr_var    = arg_var{i};     
    curr_name   = genvarname(var_name); 
    eval([curr_name, ' = curr_var; ']);
    save(curr_file, curr_name, '-v7.3'); 
end


end