% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTraj(mriAcquisition_node)

traj_type       = mriAcquisition_node.traj_type; 
imDim           = mriAcquisition_node.imDim; 
nSeg            = mriAcquisition_node.nSeg; 
nShot           = mriAcquisition_node.nShot; 
N               = mriAcquisition_node.N; 
selfNav_flag    = mriAcquisition_node.selfNav_flag;
nShot_off       = mriAcquisition_node.nShot_off;


t = []; 
if strcmp(traj_type, 'full_radial3_phylotaxis')
    t = bmTraj_fullRadial3_phyllotaxis_lineAssym2(mriAcquisition_node); 
else
    
    error('bmTraj : traj_type is unknown. ');
   return; 
end



end