% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmEuclideProd(x1, x2, H)

if iscell(x1) & iscell(x2) & iscell(H)
    
    N = size(x1(:), 1);
    
    out = 0;
    
    if bmIsScalar(H{1})
        for i = 1:N
            out = out + real(  bmCol(x1{i})'*(H{i}*bmCol(x2{i})  )  );
        end
    else
        for i = 1:N
            out = out + real(  bmCol(x1{i})'*(  bmCol(H{i}).*bmCol(x2{i})  )  );
        end
    end
    
elseif iscell(x1) & iscell(x2) & ~iscell(H)
    
    N = size(x1(:), 1);
    
    out = 0;
    
    if bmIsScalar(H)
        for i = 1:N
            out = out + real(  bmCol(x1{i})'*(H*bmCol(x2{i})  )  );
        end
    else
        for i = 1:N
            out = out + real(  bmCol(x1{i})'*(  H(:).*bmCol(x2{i})  )  );
        end
    end
    
elseif ~iscell(x1) & ~iscell(x2) & ~iscell(H)
    
    if bmIsScalar(H)
        out = real(  x1(:)'*(H*x2(:)  )  );
    else
        out = real(  x1(:)'*(H(:).*x2(:)  )  );
    end
    
else
    error('In bmEuclideProd : case not implemented. ')
end


end