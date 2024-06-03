% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

classdef bmSparseMat < handle
    properties (Access = public)
        
        % All lists must be line vectors, not column. That means that their size
        % must be of the form [1, length(list)].
        
        % All indices must be int32 excepted m_block_start which is int64. 
        % All floating point values must be single precision.
        
        r_size  = int32([]);    % Right size of the matrix. Scalar.
        r_ind   = int32([]);    % This is the list of right index. Vector.
        r_jump  = int32([]);    % This is the list of right jump. Vector.
        r_nJump = int32([]);    % This is a list, one entry for each line of the matrix.
                                % It has the length equal to l_nJump in any case. Vector.
        
        m_val   = single([]);    % This is paired to r_jump. Vector.
        
        
        l_size  = int32([]);    % Left size of the matrix. Scalar.
        l_ind   = int32([]);    % This is the index list of non zero left entry. It is empty by default.
        l_jump  = int32([]);    % This is empty if there is no left sparsity. If it is empty, it is interpretated as a list of ones of length l_size. Vector.
        l_nJump = int32([]);    % This is the number of l_jump, and is equal to l_size if l_jump is empty. Scalar.
        
        
        nBlock          = int32([]);
        block_length    = int32([]);
        l_block_start   = int32([]);
        m_block_start   = int64([]); % int64 !!!
        
        
        
        
        N_u             = int32([]);
        d_u             = single([]);
        kernel_type     = 'void';
        nWin            = int32([]);
        kernelParam     = single([]);
        
        
        block_type      = 'void';
        type            = 'void'; % possible : void, matlab_ind, l_squeezed_matlab_ind, cpp_prepared, l_squeezed_cpp_prepared
        l_squeeze_flag  = false; 
        check_flag      = true;
        
    end
    
    
    properties (SetAccess = private, GetAccess = public)
        
    end
    
    
    
    methods
        
        
        function l_squeeze(obj) % *******************************
            
            if ~strcmp(obj.type, 'matlab_ind')
                error('The matrix must be of type ''matlab_ind '' ');
                return;
            end
            
            
            
            obj.check;
            
            % preparation of temp_mask
            temp_mask = (obj.r_nJump ~= 0);
            
            % update of r_nJump
            obj.r_nJump = int32(obj.r_nJump(temp_mask));
            
            % definition of l_ind
            temp_ind = 1:obj.l_size;
            temp_ind = temp_ind(temp_mask);
            obj.l_ind = int32(temp_ind(:)');
            
            % update of l_nJump
            obj.l_nJump = int32(size(obj.l_ind, 2));
            
            %type
            obj.type = 'l_squeezed_matlab_ind';
            obj.l_squeeze_flag = true;
            
            % check
            obj.check;
            
        end % end l_squeeze_function *************************************
        
        
        
        
        
        function cpp_prepare(obj, argMode, nJumpPerBlock_factor, blockLengthMax_factor)
            
            obj.check;
            
            if ~strcmp(obj.type, 'matlab_ind') && ~strcmp(obj.type, 'l_squeezed_matlab_ind')
                error('The matrix must be of type ''matlab_ind '' or  ''l_squeezed_matlab_ind '' ');
                return;
            end
            
            % block -------------------------------------------------------
            zero_block_flag = false;
            if strcmp(argMode, 'one_block')
                [temp_l_block_start, temp_block_length, temp_nBlock, zero_block_flag] = bmSparseMat_blockPartition(obj.r_nJump, [], [], 'one');
            elseif strcmp(argMode, 'multi_block')
                [temp_l_block_start, temp_block_length, temp_nBlock, zero_block_flag] = bmSparseMat_blockPartition(obj.r_nJump, nJumpPerBlock_factor, blockLengthMax_factor);
            else
                error('Wrong list of arguments. ');
                return;
            end
            
            if zero_block_flag
                error('The sparse matrix got a zero block. Preparation aborted.');
                return;
            else
                obj.l_block_start   = temp_l_block_start; 
                obj.block_length    = temp_block_length; 
                obj.nBlock          = temp_nBlock; 
            end
            obj.m_block_start = int64(zeros(1, obj.nBlock));
            % END block ---------------------------------------------------
            
            % definition of jumps -----------------------------------------
            obj.r_ind = double(obj.r_ind);
            obj.l_ind = double(obj.l_ind);
            
            obj.r_jump = int32(   obj.r_ind - [0, obj.r_ind(1:end-1)]   );
            if strcmp(obj.type, 'l_squeezed_matlab_ind')
                obj.l_jump  = int32(   obj.l_ind - [0, obj.l_ind(1:end-1)]   );
                obj.l_nJump = int32(size(obj.l_jump, 2));
            else
                obj.l_jump  = int32([]);
                obj.l_nJump = int32(obj.l_size);
            end
            % END definition of jumps -------------------------------------
            
            
            
            % m_block_start and jump_start --------------------------------
            temp_sum_64 = int64(0);
            current_l_start = 0;
            r_ind_size = double(size(obj.r_ind, 2));
            temp_l_squeezed_flag = strcmp(obj.type, 'l_squeezed_matlab_ind');
            
            iMax = double(obj.nBlock);
            for i = 1:iMax
                current_l_start_last = current_l_start;
                current_l_start = double(obj.l_block_start(1, i));
                
                temp_nJump_64  = int64(obj.r_nJump(1, current_l_start_last + 1:current_l_start));
                temp_increment_64 = sum( temp_nJump_64, 2, 'native'); % this sum must be done in int64 to avoid overflow form int64 to double !
                temp_sum_64 = temp_sum_64 + temp_increment_64;
                current_m_start_64 = temp_sum_64;
                obj.m_block_start(1, i) = current_m_start_64;
                
                obj.r_jump(1, current_m_start_64 + 1) = obj.r_ind(1, current_m_start_64 + 1) - 1;
                if temp_l_squeezed_flag
                    obj.l_jump(1, current_l_start + 1) = obj.l_ind(1, current_l_start + 1) - 1;
                end
            end
            % END m_block_start and jump_start ----------------------------
            
            
            
            % cleaning of indices ------------------------------------------
            obj.r_ind = int32([]);
            obj.l_ind = int32([]);
            % end cleaning of indices --------------------------------------
            
            
            obj.block_type = argMode;
            if strcmp(obj.type, 'matlab_ind')
                obj.type = 'cpp_prepared';
            elseif strcmp(obj.type, 'l_squeezed_matlab_ind')
                obj.type = 'l_squeezed_cpp_prepared';
            end
            
            obj.check;
            
        end % end cpp_prepare *********************************************
        
        
        
        function check(obj) % *********************************************
            
            
            if strcmp(obj.type, 'void')
                return;
            end
            
            
            myCheck_flag = false;
            
            myType_flag = false;
            if strcmp(obj.type, 'void')
                myType_flag = true;
            elseif strcmp(obj.type, 'matlab_ind')
                myType_flag = true;
            elseif  strcmp(obj.type, 'l_squeezed_matlab_ind')
                myType_flag = true;
            elseif strcmp(obj.type, 'cpp_prepared')
                myType_flag = true;
            elseif strcmp(obj.type, 'l_squeezed_cpp_prepared')
                myType_flag = true;
            end
            
            if ~myType_flag
                myCheck_flag = true;
                disp('Check 1 failed');
            end
            
            
            mySum =  [];
            % base checks -------------------------------------------------
            if isempty(obj.l_size) || isempty(obj.r_size) || isempty(obj.l_nJump)
                myCheck_flag = true;
                disp('Check 2.1 failed');
            elseif isempty(obj.r_nJump) || isempty(obj.m_val)
                myCheck_flag = true;
                disp('Check 2.2 failed');
            elseif size(obj.r_nJump, 1) == 0 || size(obj.r_nJump, 2) == 0
                myCheck_flag = true;
                disp('Check 2.3 failed');
            elseif size(obj.m_val, 1) == 0 || size(obj.m_val, 2) == 0
                myCheck_flag = true;
                disp('Check 2.4 failed');
            elseif obj.l_size < 2 || obj.r_size < 2 || obj.l_nJump < 2
                myCheck_flag = true;
                disp('Check 2.5 failed');
                
            elseif sum(obj.r_nJump(:) < 0) > 0
                myCheck_flag = true;
                disp('Check 2.6 failed');
            end
            
            
            if ~isempty(obj.r_nJump)
                mySum = sum(obj.r_nJump(:));
                if mySum == 0
                    myCheck_flag = true;
                    disp('Check 3.1 failed');
                elseif mySum ~= size(obj.m_val, 2)
                    myCheck_flag = true;
                    disp('Check 3.2 failed');
                end
                if (size(obj.r_nJump, 2) ~= obj.l_nJump)
                    myCheck_flag = true;
                    disp('Check 3.3 failed');
                end
            end
            % END base checks ---------------------------------------------
            
            
            
            
            if strcmp(obj.type, 'matlab_ind') || strcmp(obj.type, 'l_squeezed_matlab_ind')
                if isempty(obj.r_ind)
                    myCheck_flag = true;
                    disp('Check 4.1 failed');
                elseif size(obj.r_ind, 1) == 0 || size(obj.r_ind, 2) < 2
                    myCheck_flag = true;
                    disp('Check 4.2 failed');
                end
                
                if ~isempty(mySum)
                    if mySum ~= size(obj.r_ind, 2)
                        myCheck_flag = true;
                        disp('Check 5.1 failed');
                    end
                end
            end
            
            
            if strcmp(obj.type, 'matlab_ind')
                if obj.l_nJump ~= obj.l_size
                    myCheck_flag = true;
                    disp('Check 6.1 failed');
                end
                if ~isempty(obj.r_jump) || ~isempty(obj.l_jump) || ~isempty(obj.l_ind)
                    myCheck_flag = true;
                    disp('Check 6.2 failed');
                end
                if obj.l_squeeze_flag
                    myCheck_flag = true;
                    disp('Check 6.3 failed');
                end
            end
            
            
            if strcmp(obj.type, 'l_squeezed_matlab_ind')
                if isempty(obj.l_ind)
                    myCheck_flag = true;
                    disp('Check 7.1 failed');
                elseif size(obj.l_ind, 1) == 0 || size(obj.l_ind, 2) < 2
                    myCheck_flag = true;
                    disp('Check 7.2 failed');
                end
                
                if obj.l_nJump ~= size(obj.l_ind, 2)
                    myCheck_flag = true;
                    disp('Check 7.3 failed');
                end
                
                if ~(obj.l_squeeze_flag)
                    myCheck_flag = true;
                    disp('Check 7.4 failed');
                end
            end
            
            
            
            if strcmp(obj.type, 'cpp_prepared') || strcmp(obj.type, 'l_squeezed_cpp_prepared')
                if ~isempty(obj.r_ind) || ~isempty(obj.l_ind)
                    myCheck_flag = true;
                    disp('Check 8.1 failed');
                end
                if isempty(obj.r_jump)
                    myCheck_flag = true;
                    disp('Check 8.2 failed');
                end
            end
            
            if strcmp(obj.type, 'cpp_prepared')
                if ~isempty(obj.l_jump)
                    myCheck_flag = true;
                    disp('Check 9.1 failed');
                end
                if ~isempty(mySum)
                    if mySum ~= size(obj.r_jump, 2)
                        myCheck_flag = true;
                        disp('Check 9.2 failed');
                    end
                end
                if obj.l_squeeze_flag
                    myCheck_flag = true;
                    disp('Check 9.3 failed');
                end
            end
            
            
            if strcmp(obj.type, 'l_squeezed_cpp_prepared')
                if isempty(obj.l_jump)
                    myCheck_flag = true;
                    disp('Check 10.1 failed');
                end
                if size(obj.l_jump, 2) ~= obj.l_nJump
                    myCheck_flag = true;
                    disp('Check 10.2 failed');
                end
                if ~(obj.l_squeeze_flag)
                    myCheck_flag = true;
                    disp('Check 10.3 failed');
                end
                
            end
            
            
            
            
            if not(obj.r_size < intmax('int32')) || not(obj.l_size < intmax('int32'))
                myCheck_flag = true;
                disp('Check 11.1 failed');
            end
            if not(isempty(obj.l_nJump))
                if not(obj.l_nJump < intmax('int32'))
                    myCheck_flag = true;
                    disp('Check 11.2 failed');
                end
            end
            
            
            
            
            if myCheck_flag
                obj.check_flag = false;
            end
            
            if ~obj.check_flag
                error('The sparse matrix did NOT pass the check ! ');
                return;
            end
            
            
            
        end % END check function ******************************************
        
        
        
    end % END method
end % END class



