function [l_block_start, block_length, nBlock, zero_block_flag] = bmSparseMat_blockPartition(r_nJump, nJumpPerBlock_factor, blockLengthMax_factor, varargin)
% [l_block_start, block_length, nBlock, zero_block_flag] = ...
% bmSparseMat_blockPartition(r_nJump, nJumpPerBlock_factor, ...
% blockLengthMax_factor, varargin)
%
% This function partitiones the r_nJump array into blocks.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   r_nJump (array): Contains for each point the number of points in the
%    second dimension of the sparse matrix, the number of indices jumped in 
%    a flattened array to get to the next point.
%   nJumpPerBlock_factor: Factor of the maximum of number of jumps in 
%    r_nJump that gives the maximum number of jumps allowed to be in one 
%    block. (sum of entries)
%   blockLengthMax_factor: Factor of the maximum of number of jumps in 
%    r_nJump that gives the maximum number of indices allowed to be in one 
%    block. (sum of indices)
%   varargin{1} (char): Contains 'one' the array should only be partitioned 
%    into one block. 
%
% Returns:
%   l_block_start: Integer or row vector containing start index of each 
%   block.
%   block_length: Integer or row vector containing length of each block.
%   nBlock (int): Contains the number of blocks.
%   zero_block_flag (bool): Is true if the sum of jumps for any block is
%   zero or negative.


zero_block_flag = false; 
% Calculate number of non-zero entries in sparse matrix
r_nJump_sum = sum(r_nJump(:)); 


%% Initial check for valid r_nJump
if r_nJump_sum <= 0
    nBlock = int32([]); 
    block_length = int32([]); 
    l_block_start = int32([]); 
    zero_block_flag = true; 
    return; 
end


%% Trivial case : one block only 
if ~isempty(varargin)
    if strcmp(varargin{1}, 'one') % Fill output variables
        nBlock = int32(1); 
        l_block_start = int32(0); 
        block_length = int32(   size(r_nJump(:)', 2)   ); 
        return; 
    end
end


%% Initialize multiblock
l_nJump = size(r_nJump(:)', 2);
r_nJump_max = max(r_nJump(:));
nBlock = 0;

% Number of jumps allowed per block
nJumpPerBlock       = fix(nJumpPerBlock_factor*r_nJump_max)+1; 

% Maximum length of each block
block_length_max    = fix(blockLengthMax_factor*r_nJump_max); 


% Loop initialization variables
current_l_block_start_last = 0;
current_block_length_last  = 0;


%% Determine the number of blocks and their lengths
for i = 0:l_nJump-1
    % Start index of the current block
    current_l_block_start = current_l_block_start_last + current_block_length_last;

    % Break the loop if start index exceeds the length of r_nJump
    if not(current_l_block_start < l_nJump)
        break;
    end
    
    % Initial length and index of the current block, increment block count
    nBlock = nBlock + 1;
    current_block_length = 1;
    ind_next = current_l_block_start + 1;
    
    % Check if the next index is within the length of r_nJump
    if (ind_next < l_nJump) 
        current_nJump_2 = r_nJump(1, current_l_block_start + 1);

        % Loop to determine the block length
        while (ind_next < l_nJump) 
            
            current_nJump_1 = current_nJump_2; 
            current_nJump_2 = current_nJump_1 + r_nJump(1, ind_next + 1);
            
            % Check if the current block can be extended, leave loop to
            % start next block otherwise
            if (current_nJump_2 < nJumpPerBlock) && (current_block_length < block_length_max)
                current_block_length = current_block_length + 1;
                ind_next = ind_next + 1;
            else
                break; 
            end
        end

        % Check if the sum of jumps in the current block is zero
        temp_r_nJump = r_nJump(1, current_l_block_start + 1: current_l_block_start + current_block_length); 
        if sum(temp_r_nJump(:)) <= 0
            zero_block_flag = true; 
        end
        
        % Update last block start index and length to update next block
        current_l_block_start_last = current_l_block_start;
        current_block_length_last  = current_block_length;
    
    else
        % Check if the sum of jumps in the last segment is zero
        temp_r_nJump = r_nJump(1, current_l_block_start + 1: current_l_block_start + current_block_length); 
        if sum(temp_r_nJump(:)) <= 0
            zero_block_flag = true; 
        end
        break;
    end
    
end % end for i



% These are the two we want to construct
l_block_start = int32(zeros(1, nBlock));
block_length  = int32(zeros(1, nBlock));

% Loop initialization
i_max = nBlock - 1;

r_nJump = int32(r_nJump); 
l_nJump = int32(l_nJump); 

nBlock = int32(0);
current_l_block_start = int32(0); 
current_block_length  = int32(0); 

current_l_block_start_last = int32(0);
current_block_length_last = int32(0);

ind_next = int32(0); 
current_nJump_1 = int32(0); 
current_nJump_2 = int32(0); 

nJumpPerBlock    = int32(nJumpPerBlock); 
block_length_max = int32(block_length_max); 



%% Loop to populate l_block_start and block_length
for i = 0:i_max
    % Start index of the current block
    current_l_block_start = current_l_block_start_last + current_block_length_last;

    % Break the loop if start index exceeds the length of r_nJump
    if not(current_l_block_start < l_nJump)
        break;
    end
    
    % Initial length and index of the current block, increment block count
    nBlock = nBlock + 1;
    current_block_length = 1;
    ind_next = current_l_block_start + 1;
    
    % Check if the next index is within the length of r_nJump
    if (ind_next < l_nJump) 
        current_nJump_2 = r_nJump(1, current_l_block_start + 1);

        % Loop to determine the block length
        while (ind_next < l_nJump) 
            
            current_nJump_1 = current_nJump_2; 
            current_nJump_2 = current_nJump_1 + r_nJump(1, ind_next + 1);
            
            % Check if the current block can be extended, leave loop to
            % start next block otherwise
            if (current_nJump_2 < nJumpPerBlock) && (current_block_length < block_length_max)
                current_block_length = current_block_length + 1;
                ind_next = ind_next + 1;
            else
                break; 
            end
        end

        % Populate block start index and length
        l_block_start(1, i+1) = current_l_block_start;
        block_length(1, i+1)  = current_block_length;
        
        % Update last block start index and length to update next block
        current_l_block_start_last = current_l_block_start;
        current_block_length_last  = current_block_length;

        
    else
        % Populate block start index and length for the last segment
        l_block_start(1, i+1) = current_l_block_start;
        block_length(1, i+1)  = current_block_length;
        break;
    end
    
    
    
end % end for i



end