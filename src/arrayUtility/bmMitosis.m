function varargout = bmMitosis(varargin)
% bmMitosis - Process multiple input tables and masks, and return filtered tables.
%
% Usage:
%   [outTable1, outTable2, ..., outTableN] = bmMitosis(table1, table2, ..., tableN, mask1, mask2, ..., maskM)
%   [outTable1, outTable2, ..., outTableN] = bmMitosis(table1, table2, ..., tableN, maskCellArray)
%
% Inputs:
%   table1, table2, ..., tableN : Input tables (arrays) where N is the number of output tables requested.
%   mask1, mask2, ..., maskM    : Individual mask matrices (optional if masks are provided in a cell array).
%   maskCellArray               : A cell array containing all the mask matrices.
%
% Outputs:
%   outTable1, outTable2, ..., outTableN : Output tables after processing with the masks.
%
% The function expects:
%   - The first N arguments are the input tables.
%   - The remaining arguments are either individual mask matrices or a single cell array containing all masks.
%   - All input tables must have the same number of columns (last dimension).
%   - Masks must be 2-dimensional matrices with the same number of columns as the input tables.
%
% Example 1 - Using individual masks:
%   out1, out2 = bmMitosis(table1, table2, mask1, mask2);
%
% Example 2 - Using a cell array of masks:
%   masks = {mask1, mask2};
%   out1, out2 = bmMitosis(table1, table2, masks);
%
% Author:
%   Bastien Milani, CHUV and UNIL, Lausanne, Switzerland, May 2023

nTable = nargout; 
nMask  = nargin - nTable; 

if (nTable < 1) || (nMask < 1)
   error('Wrong list of argumnts');
   return; 
end

nOfCol      = size(varargin{1}, ndims(varargin{1})); 
in_size     = cell(nTable, 1); 
new_size    = zeros(nTable, 2);

%% ASK Bastien
for j = 1:nTable
    % Here we compute the newsize, which is a reshaping of the tables
    temp_size     = size(varargin{j});
    temp_size     = temp_size(:)';
    in_size{j, 1} = temp_size(1, 1:end-1); 
    temp_nOfCol   = temp_size(1, end);
    % This seems to be flattening all the dimentions of the table except
    % the last one that is kept integer; but honestly super wird
    temp_size   = temp_size(1, 1:end-1);
    temp_size   = prod(temp_size(:)); 

    new_size(j, :) = [temp_size, temp_nOfCol];
    
    if temp_nOfCol ~= nOfCol
       error('The last dimension is not the same for every input array. '); 
    end
end

%% Handle input masks, put them in a common format

mask_list = []; 
% The masks is entered afte the table: hence you look at nTable + 1
% position: if is a cell list then there are more mask in one argument
% input and we put them in an object names mask_list
if iscell(varargin{nTable + 1})
    mask_list = varargin{nTable + 1}; 
    nMask = size(mask_list(:), 1); 
else
    % if it isn't a cell then we iterate over the masks and create cells
    % to, as the previous case, put them in an object names mask_list 
    mask_list = cell(nMask, 1); 
    for k = 1:nMask
       mask_list{k} = varargin{nTable + k};  
    end
end

for k = 1:nMask
    temp_size   = size(mask_list{k});
    temp_size   = temp_size(:)';     
    temp_nOfCol = temp_size(1, end);
    % Check the size is consistent between tables and masks
    if temp_nOfCol ~= nOfCol
       error('The last dimension is not the same for every input array. '); 
    end
    
    % Bin masks are two dimentionals: why? (I thought binary) maye is a 5D
    % recon?
    if ndims(mask_list{k}) ~= 2
       error('The masks must be 2Dim. '); 
    end
end




inTable_cell = cell(nTable, 1); 
for j = 1:nTable
    % There is a reshaping of the input cells to newsize(j,:) that is
    % calculated above 
   inTable_cell{j, 1} = reshape(varargin{j}, new_size(j, :));  
end

inMask_cell  = cell(nMask, 1); 
nPhase = zeros(nMask, 1); 

for k = 1:nMask
   inMask_cell{k, 1}  = mask_list{k};  
   nPhase(k, 1)       = size(mask_list{k}, 1);  
end

N_tot = prod(nPhase(:)); 
outTable_cell = cell(N_tot, nTable); 

%% Processing of the resulting outTable_cells
%% 1. compute a mask for each phase
%% 2. evaluate each table in the computed mask

for i = 1:N_tot
    % Make the index multidimentional: nPhase only contains the
    % sizes of the masklists.
    myIndex = bmIndex2MultiIndex(i, nPhase); 
    myIndex = myIndex(:)'; 
    % compute a one mask for each phase
    myMask = true(1, nOfCol); 
    for k = 1:nMask
        temp_mask = inMask_cell{k, 1}; 
        myMask = myMask & (  temp_mask(myIndex(1, k), :)  ); 
    end
    % Evaluate each table in the mask
    for j = 1:nTable
        temp_size = [in_size{j, 1}, sum(myMask(:))];
        temp_table = inTable_cell{j, 1}; 
        outTable_cell{i, j} = reshape(temp_table(:, myMask), temp_size); 
    end    
end

for j = 1:nTable
    varargout{j} = outTable_cell(:, j); 
end

end