function varargout = bmCoilSense_nonCart_dataFromTwix(argFile, N_u, N, nSeg, nShot, nCh, FoV, nShotOff)

myTwix      = bmTwix(argFile);  
dK_u_raw    = [1, 1, 1]./FoV;  


myMriAcquisition_node                = bmMriAcquisitionParam([]); 
myMriAcquisition_node.N              = N; 
myMriAcquisition_node.nSeg           = nSeg; 
myMriAcquisition_node.nShot          = nShot;
myMriAcquisition_node.FoV            = FoV; 
myMriAcquisition_node.nCh            = nCh; 
myMriAcquisition_node.nEcho          = 1; 

myMriAcquisition_node.selfNav_flag   = true; 
myMriAcquisition_node.nShot_off      = nShotOff; 
myMriAcquisition_node.roosk_flag     = false; 


y = bmTwix_data(myTwix, myMriAcquisition_node);
t = bmPointReshape(bmTraj_fullRadial3_phyllotaxis_lineAssym2(myMriAcquisition_node));


if (nargout ==  1) || (nargout == 2)
    ve      = ones(1, size(t, 2));
elseif nargout == 3
    ve      = bmVolumeElement(t, 'voronoi_full_radial3');
end

[y, t, ve]  = bmLowRes(y, t, ve, N_u, dK_u_raw);
y           = bmPermuteToCol(y); 

    
if nargout > 0 
    varargout{1}    = y;
end
if nargout > 1
    varargout{2}    = t;
end
if nargout > 2
    varargout{3}    = ve;
end

    
end