% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myFlag = bmSparseMat_isequal(s, t)

myFlag = true;

if ~isequal(s.r_size, t.r_size)
    myFlag = false;
    return ;
end

if ~isequal(s.r_ind, t.r_ind)
    myFlag = false;
    return ;
end

if ~isequal(s.r_jump, t.r_jump)
    myFlag = false;
    return ;
end

if ~isequal(s.r_nJump, t.r_nJump)
    myFlag = false;
    return ;
end



if ~isequal(s.m_val, t.m_val)
    myFlag = false;
    return ;
end



if ~isequal(s.l_size, t.l_size)
    myFlag = false;
    return ;
end

if ~isequal(s.l_ind, t.l_ind)
    myFlag = false;
    return ;
end

if ~isequal(s.l_jump, t.l_jump)
    myFlag = false;
    return ;
end

if ~isequal(s.l_nJump, t.l_nJump)
    myFlag = false;
    return ;
end



if ~isequal(s.nBlock, t.nBlock)
    myFlag = false;
    return ;
end

if ~isequal(s.block_length, t.block_length)
    myFlag = false;
    return ;
end

if ~isequal(s.l_block_start, t.l_block_start)
    myFlag = false;
    return ;
end

if ~isequal(s.m_block_start, t.m_block_start)
    myFlag = false;
    return ;
end


if ~isequal(s.N_u, t.N_u)
    myFlag = false;
    return ;
end


if ~isequal(s.d_u, t.d_u)
    myFlag = false;
    return ;
end


if ~isequal(s.kernel_type, t.kernel_type)
    myFlag = false;
    return ;
end

if ~isequal(s.nWin, t.nWin)
    myFlag = false;
    return ;
end

if ~isequal(s.kernelParam, t.kernelParam)
    myFlag = false;
    return ;
end





if ~isequal(s.block_type, t.block_type)
    myFlag = false;
    return ;
end

if ~isequal(s.type, t.type)
    myFlag = false;
    return ;
end

if ~isequal(s.l_squeeze_flag, t.l_squeeze_flag)
    myFlag = false;
    return ;
end

if ~isequal(s.check_flag, t.check_flag)
    myFlag = false;
    return ;
end


end