function w = bmSparseMat_vec(s, v, varargin)
% w = bmSparseMat_vec(s, v, varargin)
%
% This function performes sparse matrix-matrix multiplication using mex
% functions to perform the computation efficiently in c++.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   s (bmSparseMat): Sparse matrix object that contains the left matrix of 
%    the matrix multiplication.
%   v (2D array): Matrix containing vectors of data. The length of the
%    vectors must be the same size as the columns of the sparse matrix.
%    This is the right matrix of the matrix multiplication.
%   varargin{1}: Char containing 'omp', or a logical. If 'omp' or true, the
%    computation uses openMP to perform parallel processing using threads.
%    The default value is false.
%   varargin{2}: Char containing 'complex' or 'real', or a logical. If
%    'complex' or false, the v is processed as a complex vector, otherwise,
%    v is assumed to be real. The default value is true ('real')
%   varargin{3}: Logical flag if v has to be transposed. If true, v is
%    processed as containing row vectors (row length = sparse column 
%    length). If false, v is processed as containing column vectors (column 
%    length = sparse column length). If not given, the dimension of smaller
%    size is assumed to contain the vectors, as normally there is more data 
%    than vectors.
%
% Returns:
%   w (2D array): Result of the matrix multiplication. Real or complex,
%    depending on the input.

%% Trivial case (empty input)
if isempty(s)
    w = []; 
    return; 
end
if isempty(v)
    w = []; 
    return; 
end


%% Critical check
% Check if bmSparseMat properties are correct
s.check; 

% Check if input is correct / usable
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


%% Set flag for using openMP (parallel processing)
omp_flag = [];
if ~isempty(varargin)
    if strcmp(varargin{1}, 'omp')
        omp_flag = true;
    elseif islogical(varargin{1})
        omp_flag = varargin{1};
    end
end

% Default value
if isempty(omp_flag) 
    omp_flag = false; 
end


%% Set flag for real (true) or complex (false) input 
R_flag = [];
if length(varargin) > 1
    if strcmp(varargin{2}, 'complex')
        R_flag = false;
    elseif strcmp(varargin{2}, 'real')
        R_flag = true;
    elseif islogical(varargin{1})
        R_flag = varargin{2};
    end
end

% Default value
if isempty(R_flag)
    R_flag = true; 
end


%% Set flag for row (true) or column (false) vector -> Transpose v if true
T_flag = []; 
if length(varargin) > 2
    T_flag = varargin{3}; 
    if T_flag || strcmp(T_flag, 'T') 
        % v contains row vectors (each row contains data of one channel)
        n_vec_32 = int32(size(v, 1)); 
        T_flag = true; 
    else
        % v contains column vectors (each column contains data)
        n_vec_32 = int32(size(v, 2)); 
        T_flag = false;
    end
end

% Set default value (guess value)
if isempty(T_flag)
    v_size = size(v);
    v_size = v_size(:)';
    n_vec_32 = int32(0);
    T_flag = false;

    % Assume there to be more data than vectors
    if v_size(1, 1) >= v_size(1, 2) 
        n_vec_32 = int32(size(v, 2));
        T_flag = false;
    else
        n_vec_32 = int32(size(v, 1));
        T_flag = true;
    end
end


%% Set other_flags

if isempty(s.l_jump)
    l_squeeze_flag = false;
else
    l_squeeze_flag = true;
end

% All on block or as multiblock
one_block_flag = true;
if strcmp(s.block_type, 'one_block')
    one_block_flag = true; 
elseif strcmp(s.block_type, 'multi_block')
    one_block_flag = false; 
end


%% Call computation function depending on flags
if T_flag % Row vectors
    if R_flag % Real input
        if one_block_flag % One block
            if omp_flag % Use openMP
                error('Case not implemented.');
                return;

            else % Don't use openMP
                disp('bmSparseMat_rR_oBlock_mex'); 
                % Perform sparse matrix - vector multiplication for every
                % real row vector in v using c++. The returned matrix is
                % the result of the multiplication.
                w = bmSparseMat_rR_oBlock_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);
            end

        else % Multiblock
            if omp_flag % Use openMP
                disp('bmSparseMat_rR_nBlock_omp_mex'); 
                % Perform sparse matrix - vector multiplication for every
                % real row vector in v, which is partitioned into 
                % blocks, using parallel processing in c++. The returned 
                % matrix is the result of the multiplication.
                w = bmSparseMat_rR_nBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    s.nBlock, s.block_length, s.l_block_start, s.m_block_start, ...
                    v, n_vec_32);

            else % Don't use openMP
                error('Case not implemented.');
                return;
            end
        end

    else % Complex input
        if one_block_flag % One block
            if omp_flag % Use openMP
                error('Case not implemented.');
                return;

            else % Don't use openMP
                disp('bmSparseMat_cR_oBlock_mex');
                % Perform sparse matrix - vector multiplication for every
                % complex row vector in v in c++. The returned matrices 
                % are the real and imaginary part of the result.
                [w_real, w_imag] = bmSparseMat_cR_oBlock_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    real(v), imag(v), n_vec_32);
                w = w_real + 1i*w_imag; 
            end

        else % Multiblock
            if omp_flag % Use openMP
                % Perform sparse matrix - vector multiplication for every
                % complex row vector in v, which is partitioned into 
                % blocks, using parallel processing in c++. The returned 
                % matrices are the real and imaginary part of the result.
                disp('bmSparseMat_cR_nBlock_omp_mex'); 
                [w_real, w_imag] = bmSparseMat_cR_nBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    s.nBlock, s.block_length, s.l_block_start, s.m_block_start, ...
                    real(v), imag(v), n_vec_32);
                w = w_real + 1i*w_imag; 

            else % Don't use openMP
                error('Case not implemented');
                return;
            end
        end
    end
  
else % Column vectors
    if R_flag % Real input
        if one_block_flag % One block
            if omp_flag % Use openMP
                disp('bmSparseMat_rC_oBlock_omp_mex'); 
                % Perform sparse matrix - vector multiplication for every
                % real column vector in v using parallel processing in 
                % c++. The returned matrix is the result of the 
                % multiplication.
                w = bmSparseMat_rC_oBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);

            else % Don't use openMP
                disp('bmSparseMat_rC_oBlock_mex'); 
                % Perform sparse matrix - vector multiplication for every
                % real column vector in v using c++. The returned matrix is
                % the result of the multiplication.
                w = bmSparseMat_rC_oBlock_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    v, n_vec_32);
            end

        else % Multiblock
            error('Case not implemented'); 
            return; 
        end

    else % Complex input
        if one_block_flag % One block
            if omp_flag % Use openMP
                % disp('bmSparseMat_cC_oBlock_omp_mex'); 
                % Perform sparse matrix - vector multiplication for every
                % complex column vector in v using parallel processing in 
                % c++. The returned matrices are the real and imaginary
                % part of the result.
                [w_real, w_imag] = bmSparseMat_cC_oBlock_omp_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    real(v), imag(v), n_vec_32);
                w = w_real + 1i*w_imag; 

            else % Don't use openMP
                % disp('bmSparseMat_cC_oBlock_mex'); 
                % Perform sparse matrix - vector multiplication for every
                % complex column vector in v in c++. The returned matrices 
                % are the real and imaginary part of the result.
                [w_real, w_imag] = bmSparseMat_cC_oBlock_mex(...
                    s.r_size, s.r_jump, s.r_nJump, ...
                    s.m_val, ...
                    s.l_size, s.l_jump, s.l_nJump, l_squeeze_flag, ...
                    real(v), imag(v), n_vec_32);
                w = w_real + 1i*w_imag; 
            end

        else % Multiblock
            error('Case not implemented'); 
            return; 
        end
    end
end
end

