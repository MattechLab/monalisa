% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% 'simbaCluster' is a list of num of shots. 

function lineMask = bmSimbaCluster_to_lineMask(simbaCluster, nSeg, nShot)
 
nMask       = size(simbaCluster(:), 1); 
lineMask    = false(nMask, nSeg, nShot);

for i = 1:nMask
    lineMask(i, :, simbaCluster{i}(:)') = true;
end

lineMask = reshape(lineMask, [nMask, nSeg*nShot]); 

end