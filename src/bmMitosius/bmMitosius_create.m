% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


function bmMitosius_create(mitosius_dir, varargin)

y_cell          = []; 
t_cell          = []; 
ve_cell         = []; 

mitosius_size   = [];
mitosius_ndims  = [];
mitosius_length = [];

if nargin == 2
    mitosius_length = varargin{1}; 
elseif nargin == 4
    y_cell  = varargin{1}; 
    t_cell  = varargin{2}; 
    ve_cell = varargin{3}; 
    
    mitosius_size   = size(y_cell); 
    mitosius_ndims  = size(mitosius_size(:), 1); 
    mitosius_length = prod(mitosius_size(:)); 
end

bmCreateDir(mitosius_dir); 
for i = 1:mitosius_length
   
   myIndex = bmCol(  bmIndex2MultiIndex(i, mitosius_size)  )'; 
   num_id = []; 
   for j = 1:size(  myIndex(:), 1  )
      num_id = cat(2, num_id, '_', num2str(myIndex(1, j))  );  
   end   
   
   bmCreateDir([mitosius_dir, '/cell', num_id]); 
   
   if ~isempty(y_cell)
       y = y_cell{i};
       save([mitosius_dir, '/cell', num_id, '/y'],  'y',  '-v7.3');
   end
   if ~isempty(t_cell)
       t = t_cell{i};
       save([mitosius_dir, '/cell', num_id, '/t'],  't',  '-v7.3');
   end
   if ~isempty(ve_cell)
       ve = ve_cell{i};
       save([mitosius_dir, '/cell', num_id, '/ve'], 've', '-v7.3');
   end
   
end

save([mitosius_dir, '/mitosius_size'], 'mitosius_size', '-v7.3');

end