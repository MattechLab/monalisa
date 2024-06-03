% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function ve_out = bmY_ve_reshape(ve, y_size)

y_size  = y_size(:)'; 
if (size(ve, 1) == y_size(1, 1)) && (size(ve, 2) == y_size(1, 2))
    ve_out = ve; 
    return; 
end

nPt      = y_size(1, 1); 
nCh      = y_size(1, 2); 
if (nPt == 1) && (nCh == 1)
   error('ve is not reshapable in the given size. ');  
   return; 
end

s1 = size(ve, 1); 
s2 = size(ve, 2); 

rawFlag = false; 
if (nPt < nCh)
    rawFlag = true; 
    temp = nPt; 
    nPt  = nCh; 
    nCh  = temp; 
end


if (s1 == 1) && (s2 == 1)
    ve_out = ve*ones(nPt, nCh);
elseif (s1 > 1) && (s2 == 1)
    ve_out = repmat(ve, [1, nCh]);
elseif (s1 == 1) && (s2 > 1)
    ve_out = repmat(ve(:), [1, nCh]);
elseif (s1 > 1) && (s2 > 1)
    if not(s1 == nPt) || not(s2 == nCh)
        ve_out = ve.';
    end
end


if rawFlag
   ve_out = ve_out.';  
end


if not(isequal(size(ve_out), y_size))
    error('ve is not reshapable in the given size. '); 
    return; 
end

end