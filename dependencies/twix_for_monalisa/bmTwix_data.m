function y_raw = bmTwix_data(myTwix, myMriAcquisition_node)

N               = myMriAcquisition_node.N; 
nSeg            = myMriAcquisition_node.nSeg;  
nShot           = myMriAcquisition_node.nShot;  
nCh             = myMriAcquisition_node.nCh; 
nEcho           = myMriAcquisition_node.nEcho; 

selfNav_flag    = myMriAcquisition_node.selfNav_flag; 
nShot_off       = myMriAcquisition_node.nShot_off; 
roosk_flag      = myMriAcquisition_node.roosk_flag;


y_raw   = myTwix.image.unsorted();
if nEcho == 1
    y_raw   = permute(y_raw, [2, 1, 3]);
    y_raw   = reshape(y_raw, [nCh, N, nSeg, nShot]);
    
    if selfNav_flag
        y_raw(:, :, 1, :) = [];
        nSeg = nSeg - 1;
    end
    if nShot_off > 0
        y_raw(:, :, :, 1:nShot_off) = NaN;
        % nShot = nShot - nShot_off;
    end
    if roosk_flag
        y_raw = y_raw(:, 1:2:end, :, :);
        N = N/2;
    end
    y_raw  = reshape(y_raw, [nCh, N, nSeg*nShot]);
elseif nEcho == 2
    error('bmTwix_data : nEcho == 2, case not implemented, yet. But we have to do it for Giulia''s data ! ');
    return; 
else
    error('bmTwix_data : case not implemented. ');
    return; 
end

 



end
