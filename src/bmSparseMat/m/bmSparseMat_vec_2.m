% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function w = bmSparseMat_vec_2(s, v, varargin)

if ndims(v) > 2
   error('The input list of vectors ''v'' is a matrix that cannot have more that 2 dim. ');
   return; 
end

if strcmp(class(s), 'bmSparseMat')
   if not(  strcmp(class(v), 'single')  )
      error('The class bmSparseMat is for single class only. '); 
      return; 
   end
else
   if not(  strcmp(class(v), 'double')  )
       error('Matlab sparse matrices are implemented for double class only. '); 
       return; 
   end
end



if not(strcmp(class(s), 'bmSparseMat')) && strcmp(class(v), 'double')
    w = s*v; 
    return; 
end


omp_flag = false;
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


if isempty(s.l_jump)
    l_squeeze_flag = false;
else
    l_squeeze_flag = true;
end

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


R_flag = true; 
if isreal(v)
    R_flag = true; 
else
    R_flag = false; 
end


one_block_flag = true;
if strcmp(s.block_type, 'one_block')
    one_block_flag = true; 
elseif strcmp(s.block_type, 'multi_block')
    one_block_flag = false; 
else
    error('The bmSparseMat is not cpp_prepared. ');
    return;
end
    
    

if T_flag
    
    
    if R_flag
        if one_block_flag
            
            w = bmSparseMat_rR_oBlock_mex(...
                s.r_size, s.r_jump, s.r_nJump, ...
                s.m_val, ...
                s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                v, n_vec_32);
            
        else % not one_block_flag
            if omp_flag
            
                w = bmSparseMat_rR_nBlock_mex_omp(...
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
            
            w = bmSparseMat_cR_oBlock_2_mex(...
                s.r_size, s.r_jump, s.r_nJump, ...
                s.m_val, ...
                s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                v, n_vec_32);
            
        else % not one_block_flag
            if omp_flag
                w = bmSparseMat_cR_nBlock_2_mex_omp(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    s.nBlock, s.block_length, s.l_block_start, s.m_block_start, ...
                    v, n_vec_32);
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
                w = bmSparseMat_rC_oBlock_mex_omp(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);
            else
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
                w = bmSparseMat_cC_oBlock_2_mex_omp(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);
            else % not omp_flag
                w = bmSparseMat_cC_oBlock_2_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);
            end
        else % not one_block_flag
            error('Case not implemented'); 
            return; 
            
        end
        
    end
    
end



end

