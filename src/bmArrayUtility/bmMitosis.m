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
for j = 1:nTable
    temp_size     = size(varargin{j});
    temp_size     = temp_size(:)';
    in_size{j, 1} = temp_size(1, 1:end-1); 
    temp_nOfCol   = temp_size(1, end);
    
    temp_size   = temp_size(1, 1:end-1);
    temp_size   = prod(temp_size(:)); 
    new_size(j, :) = [temp_size, temp_nOfCol];
    
    if temp_nOfCol ~= nOfCol
       error('The last dimension is not the same for every input array. '); 
       return; 
    end
end

mask_list = []; 
if iscell(varargin{nTable + 1})
    mask_list = varargin{nTable + 1}; 
    nMask = size(mask_list(:), 1); 
else
    mask_list = cell(nMask, 1); 
    for k = 1:nMask
       mask_list{k} = varargin{nTable + k};  
    end
end

for k = 1:nMask
    temp_size   = size(mask_list{k});
    temp_size   = temp_size(:)';     
    temp_nOfCol = temp_size(1, end);
    
    if temp_nOfCol ~= nOfCol
       error('The last dimension is not the same for every input array. '); 
       return; 
    end
    
    if ndims(mask_list{k}) ~= 2
       error('The masks must be 2Dim. '); 
       return; 
    end
end




inTable_cell = cell(nTable, 1); 
for j = 1:nTable
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
for i = 1:N_tot
    myIndex = bmIndex2MultiIndex(i, nPhase); 
    myIndex = myIndex(:)'; 
    
    myMask = true(1, nOfCol); 
    for k = 1:nMask
        temp_mask = inMask_cell{k, 1}; 
        myMask = myMask & (  temp_mask(myIndex(1, k), :)  ); 
    end
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