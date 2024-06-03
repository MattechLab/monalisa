% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


% varargin{1} must be 'omp' or true to use openMP. Default is false. 
% varargin{2} must be 'complex' or false for a complex vectors. Default is true.  
% varargin{3} must be 'false' for column vectore, true for raw vectors. Default is a guess. 

function w = bmSparseMat_vec(s, v, varargin)

% trivial_case ------------------------------------------------------------
if isempty(s)
    w = []; 
    return; 
end
if isempty(v)
    w = []; 
    return; 
end
% END_trivial_case --------------------------------------------------------

% critical_check ----------------------------------------------------------
s.check; 
if ndims(v) > 2
    error('The input list of vectors ''v'' is a matrix that cannot have more that 2 dim. ');
    return;
end
if not(  strcmp(class(v), 'single')  )
    error('The class bmSparseMat is for single class only. ');
    return;
end
if ~strcmp(s.block_type, 'one_block') && ~strcmp(s.block_type, 'multi_block')
    error('The bmSparseMat is not cpp_prepared. ');
    return;
end
if ~s.check_flag
    error('The bmSparseMat has check_flag to false. ')
    return;
end
% END_critical_check ------------------------------------------------------



% varargin_flags ----------------------------------------------------------
omp_flag = [];
if length(varargin) > 0
    if strcmp(varargin{1}, 'omp');
        omp_flag = true;
    elseif islogical(varargin{1})
        omp_flag = varargin{1};
    end
end
if isempty(omp_flag)
    omp_flag = false; 
end


R_flag = []; 
if length(varargin) > 1
    if strcmp(varargin{2}, 'complex');
        R_flag = false;
    elseif strcmp(varargin{2}, 'real');
        R_flag = true;
    elseif islogical(varargin{1})
        R_flag = varargin{2};
    end
end
if isempty(R_flag)
    R_flag = true; 
end


T_flag = []; 
if length(varargin) > 2
    T_flag = varargin{3}; 
    if T_flag || strcmp(T_flag, 'T')
        n_vec_32 = int32(size(v, 1));
        T_flag = true; 
    else
        n_vec_32 = int32(size(v, 2));
        T_flag = false;
    end
end
if isempty(T_flag)
    v_size = size(v);
    v_size = v_size(:)';
    n_vec_32 = int32(0);
    T_flag = false;
    if v_size(1, 1) >= v_size(1, 2);
        n_vec_32 = int32(size(v, 2));
        T_flag = false;
    else
        n_vec_32 = int32(size(v, 1));
        T_flag = true;
    end
end
% END_varargin_flags ------------------------------------------------------





% other_flags -------------------------------------------------------------
if isempty(s.l_jump)
    l_squeeze_flag = false;
else
    l_squeeze_flag = true;
end

one_block_flag = true;
if strcmp(s.block_type, 'one_block')
    one_block_flag = true; 
elseif strcmp(s.block_type, 'multi_block')
    one_block_flag = false; 
end
% END_other_flags ---------------------------------------------------------



    

% selection_from_flag -----------------------------------------------------
if T_flag
    if R_flag
        if one_block_flag
            
            disp('bmSparseMat_rR_oBlock_mex'); 
            w = bmSparseMat_rR_oBlock_mex(...
                s.r_size, s.r_jump, s.r_nJump, ...
                s.m_val, ...
                s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                v, n_vec_32);
            
        else % not one_block_flag
            if omp_flag
            
                disp('bmSparseMat_rR_nBlock_omp_mex'); 
                w = bmSparseMat_rR_nBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    s.nBlock, s.block_length, s.l_block_start, s.m_block_start, ...
                    v, n_vec_32);
            else % not omp_flag
                error('Case not implemented. ');
                return;
            end
        end
    else % not R_flag
        
        if one_block_flag
            
            disp('bmSparseMat_cR_oBlock_mex');
            [w_real, w_imag] = bmSparseMat_cR_oBlock_mex(...
                s.r_size, s.r_jump, s.r_nJump, ...
                s.m_val, ...
                s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                real(v), imag(v), n_vec_32);
            w = w_real + 1i*w_imag; 
            
        else % not one_block_flag
            if omp_flag
                
                disp('bmSparseMat_cR_nBlock_omp_mex'); 
                [w_real, w_imag] = bmSparseMat_cR_nBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    s.nBlock, s.block_length, s.l_block_start, s.m_block_start, ...
                    real(v), imag(v), n_vec_32);
                w = w_real + 1i*w_imag; 
            else % not omp_flag
                error('Case not implemented');
                return;
            end
        end
        
    end
    
    
    
else % not T_flag
    if R_flag
        if one_block_flag
            if omp_flag
                
                disp('bmSparseMat_rC_oBlock_omp_mex'); 
                w = bmSparseMat_rC_oBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);
            else
                
                disp('bmSparseMat_rC_oBlock_mex'); 
                w = bmSparseMat_rC_oBlock_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);
            end
        else % not one_block_flag
            
            error('Case not implemented'); 
            return; 
            
        end
    else % not R_flag
        if one_block_flag
            if omp_flag
                
                % disp('bmSparseMat_cC_oBlock_omp_mex'); 
                [w_real, w_imag] = bmSparseMat_cC_oBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    real(v), imag(v), n_vec_32);
                w = w_real + 1i*w_imag; 
            else % not omp_flag
                
                % disp('bmSparseMat_cC_oBlock_mex'); 
                [w_real, w_imag] = bmSparseMat_cC_oBlock_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    real(v), imag(v), n_vec_32);
                w = w_real + 1i*w_imag; 
            end
        else % not one_block_flag
            error('Case not implemented'); 
            return; 
            
        end
        
    end
    
end
% END_selection_from_flag -------------------------------------------------

end

