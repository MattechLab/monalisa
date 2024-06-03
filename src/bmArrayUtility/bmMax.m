% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function m = bmMax(x)

x = x(:); 
if iscell(x)
    nCell   = size(x(:), 1); 
    m_list  = zeros(nCell, 1); 
    for i   = 1:nCell
        m_list(i, 1) = max(x{i, 1}(:)); 
    end
    m = max(m_list(:)); 
else
    m = max(x);
end


end