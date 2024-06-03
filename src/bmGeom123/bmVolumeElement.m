% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% 
% Possible argType : 
%
% 
% voronoi_center_out_radial2
% voronoi_center_out_radial3
%
% voronoi_full_radial2
% voronoi_full_radial3
%
% voronoi_full_radial3_nonUnique
%
% voronoi_box2
% voronoi_box3
% 
% imDeformField2
% imDeformField3
%
% cartesian2
% cartesian3
%
% randomPartialCartesian2_x
% randomPartialCartesian3_x
%
% full_radial3
%
% center_out_radial3
%


function varargout = bmVolumeElement(argTraj, argType, varargin)

[N_u, dK_u] = bmVarargin(varargin); 

if iscell(argTraj)
    v  = cell(size(argTraj));
    for i = 1:size(argTraj(:), 1)
        v{i} = bmVolumeElement(argTraj{i}, argType, N_u, dK_u);
    end
    varargout{1} = v; 
    return;
end

t = bmPointReshape(argTraj); 
    
if strcmp(argType, 'voronoi_box2')
    [formatedTraj, ~, formatedIndex, formatedWeight] = bmTraj_formatTraj(t);
    v = bmVolumeElement_voronoi_box2(formatedTraj, N_u, dK_u);
    v = v(:)';
    v = v(1, formatedIndex(:)').*formatedWeight(:)';
    
elseif strcmp(argType, 'voronoi_box3')
    [formatedTraj, ~, formatedIndex, formatedWeight] = bmTraj_formatTraj(t);
    v = bmVolumeElement_voronoi_box3(formatedTraj, N_u, dK_u);
    v = v(:)';
    v = v(1, formatedIndex(:)').*formatedWeight(:)';

elseif strcmp(argType, 'voronoi_center_out_radial2')
    v = bmVolumeElement_voronoi_center_out_radial2(t);
    
elseif strcmp(argType, 'voronoi_center_out_radial3')
    v = bmVolumeElement_voronoi_center_out_radial3(t);
    
elseif strcmp(argType, 'voronoi_full_radial2')
    v = bmVolumeElement_voronoi_full_radial2(t);
    
elseif strcmp(argType, 'voronoi_full_radial3')
    v = bmVolumeElement_voronoi_full_radial3(t);

elseif strcmp(argType, 'voronoi_full_radial2_nonUnique')
    nAverage = varargin{1}; 
    v = bmVolumeElement_voronoi_full_radial2_nonUnique(t, nAverage);
    
elseif strcmp(argType, 'voronoi_full_radial3_nonUnique')
    v = bmVolumeElement_voronoi_full_radial3_nonUnique(t);
    
elseif strcmp(argType, 'imDeformField2')
    v = bmVolumeElement_imDeformField2(t, N_u);
    
elseif strcmp(argType, 'imDeformField3')
    v = bmVolumeElement_imDeformField3(t, N_u);
        
elseif strcmp(argType, 'cartesian2')
    v = bmVolumeElement_cartesian2(t);
    
elseif strcmp(argType, 'cartesian3')
    v = bmVolumeElement_cartesian3(t);

elseif strcmp(argType, 'randomPartialCartesian2_x')
    v = bmVolumeElement_randomPartialCartesian2_x(t, N_u, dK_u);
    
elseif strcmp(argType, 'randomPartialCartesian3_x')
    v = bmVolumeElement_randomPartialCartesian3_x(t, N_u, dK_u);
    
elseif strcmp(argType, 'full_radial3')
    v = bmVolumeElement_full_radial3(t);
    
elseif strcmp(argType, 'center_out_radial3')
    v = bmVolumeElement_center_out_radial3(t);

else
    error('Type is unknown'); 
    
end % END_argType

if sum(isnan(  v(:)  )) > 0
   warning('There is some NaNs in the volume elements !!! You need to replace it. ');  
end

varargout{1} = v; 

end