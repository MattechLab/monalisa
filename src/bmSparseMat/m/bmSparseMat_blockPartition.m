% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [l_block_start, block_length, nBlock, zero_block_flag] = bmSparseMat_blockPartition(r_nJump, nJumpPerBlock_factor, blockLengthMax_factor, varargin)

zero_block_flag = false; 
r_nJump_sum = sum(r_nJump(:)); 



% initial check -----------------------------------------------------------
if r_nJump_sum <= 0
    nBlock = int32([]); 
    block_length = int32([]); 
    l_block_start = int32([]); 
    zero_block_flag = true; 
    return; 
end
% END initial check -------------------------------------------------------



% trivial case : one block only -------------------------------------------
if length(varargin) > 0
    if strcmp(varargin{1}, 'one')
        nBlock = int32(1); 
        l_block_start = int32(0); 
        block_length = int32(   size(r_nJump(:)', 2)   ); 
        return; 
    end
end
% END trivial case : one block only ---------------------------------------





% initial -----------------------------------------------------------------
l_nJump = size(r_nJump(:)', 2);
r_nJump_max = max(r_nJump(:));
nBlock = 0;

nJumpPerBlock       = fix(nJumpPerBlock_factor*r_nJump_max)+1; 
block_length_max    = fix(blockLengthMax_factor*r_nJump_max); 

% end_initial -------------------------------------------------------------



% loop initial ------------------------------------------------------------
current_l_block_start_last = 0;
current_block_length_last  = 0;
% END_loop initial --------------------------------------------------------


for i = 0:l_nJump-1
    
    current_l_block_start = current_l_block_start_last + current_block_length_last;
    if not(current_l_block_start < l_nJump)
        break;
    end
    
    nBlock = nBlock + 1;
    current_block_length = 1;
    ind_next = current_l_block_start + 1;
    
    
    if (ind_next < l_nJump) 
        current_nJump_2 = r_nJump(1, current_l_block_start + 1);
        while (ind_next < l_nJump) 
            
            current_nJump_1 = current_nJump_2; 
            current_nJump_2 = current_nJump_1 + r_nJump(1, ind_next + 1);
            
            if (current_nJump_2 < nJumpPerBlock) && (current_block_length < block_length_max)
                current_block_length = current_block_length + 1;
                ind_next = ind_next + 1;
            else
                break; 
            end
        end
        
        temp_r_nJump = r_nJump(1, current_l_block_start + 1: current_l_block_start + current_block_length); 
        if sum(temp_r_nJump(:)) <= 0
            zero_block_flag = true; 
        end

        current_l_block_start_last = current_l_block_start;
        current_block_length_last  = current_block_length;
    
    else
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

% loop initial ------------------------------------------------------------
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


% END_loop initial --------------------------------------------------------


for i = 0:i_max
    
    current_l_block_start = current_l_block_start_last + current_block_length_last;
    if not(current_l_block_start < l_nJump)
        break;
    end
    
    nBlock = nBlock + 1;
    current_block_length = 1;
    ind_next = current_l_block_start + 1;
    
    
    if (ind_next < l_nJump) 
        current_nJump_2 = r_nJump(1, current_l_block_start + 1);
        while (ind_next < l_nJump) 
            
            current_nJump_1 = current_nJump_2; 
            current_nJump_2 = current_nJump_1 + r_nJump(1, ind_next + 1);
            
            if (current_nJump_2 < nJumpPerBlock) && (current_block_length < block_length_max)
                current_block_length = current_block_length + 1;
                ind_next = ind_next + 1;
            else
                break; 
            end
        end

        
        l_block_start(1, i+1) = current_l_block_start;
        block_length(1, i+1)  = current_block_length;
        
        current_l_block_start_last = current_l_block_start;
        current_block_length_last  = current_block_length;

        
    else
        l_block_start(1, i+1) = current_l_block_start;
        block_length(1, i+1)  = current_block_length;
        break;
    end
    
    
    
end % end for i



end