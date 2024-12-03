function varargout = bmVolumeElement(argTraj, argType, varargin)
% bmVolumeElement - Compute volume elements based on different trajectory types.
%
%   varargout = bmVolumeElement(argTraj, argType, varargin)
%
% Inputs:
%   argTraj - Trajectory data. Can be a matrix or a cell array of matrices
%             representing trajectories.
%   argType - Type of volume element computation. Supported types are:
%             - 'voronoi_center_out_radial2': Computes volume using Voronoi
%               method for 2D trajectories. It's for 2D radial trajectory
%               UTE, which means that the first sampled point is in the
%               center, for each spoke.
%             - 'voronoi_center_out_radial3': Computes volume using Voronoi
%               method for 3D trajectories. It's for 3D radial trajectory
%               UTE, which means that the first sampled point is in the
%               center, for each spoke.
%             - 'center_out_radial3': Computes volume using center-out radial
%               method for 3D trajectories. It is not using Voronoi but 
%               assumes the trajectory is uniformly distributed on
%               the sphere. Faster but less precise.
%             - 'voronoi_full_radial2': Computes volume using full radial
%               method for 2D trajectories. It's for radial 2D
%               trajectories, where the spokes are full radial (diameters),
%               instead of half radial.
%             - 'voronoi_full_radial3': Computes volume using full radial
%               method for 3D trajectories. It's for radial 3D
%               trajectories, where the spokes are full radial (diameters),
%               instead of half radial.
%             - 'voronoi_full_radial2_nonUnique': Computes volume using full
%               radial method for 2D trajectories with non-unique points.
%               This is for trajectory that have duplicates, but not only
%               the center. 
%             - 'voronoi_full_radial3_nonUnique': Computes volume using full
%               radial method for 3D trajectories with non-unique points. 
%               This is for trajectory that have duplicates, but not only
%               the center.
%             - 'voronoi_box2': Computes volume using box method for 2D
%               trajectories. Cannot have duplicate. Any type of
%               trajectory. 
%             - 'voronoi_box3': Computes volume using box method for 3D
%               trajectories. Cannot have duplicate. Any type of
%               trajectory. Not computationally feasible with realistic 3D
%               acquisitions.
%             - 'imDeformField2': Computes efficiently volume elements for 2D deformation
%               field.
%             - 'imDeformField3': Computes efficiently volume elements for 3D image deformation
%               fields.
%             - 'cartesian2': Computes volume elements for 2D Cartesian
%               trajectories. Assumes that along each edge the point in
%               position N/2 + 1 is zero.
%             - 'cartesian3': Computes volume elements for 3D Cartesian acquisition 
%               trajectories. Assumes that along each edge the point in
%               position N/2 + 1 is zero.
%             - 'randomPartialCartesian2_x': Computes volume elements for 2D Cartesian
%               trajectories. Some points can be missing from the grid.
%             - 'randomPartialCartesian3_x': Computes volume using random
%               partial Cartesian method for 3D trajectories.
%             - 'full_radial3': Computes volume elements using full radial method for
%               3D trajectories. Some points can be missing from the grid.
%
%   varargin - Additional arguments required depending on the argType:
%              - For 'voronoi_full_radial2_nonUnique': Number of averages.
%              - For 'imDeformField2' and 'imDeformField3': Parameters for
%                image deformation.
%
% Outputs:
%   varargout{1} - Volume elements computed based on the specified argType.
%
% Notes:
%   - This function handles both single trajectory matrices and cell arrays
%     of trajectory matrices.
%   - It checks for NaN values in the computed volume elements and issues a
%     warning if found.
%
% Example:
%   % Compute volume elements using Voronoi method for 2D trajectories
%   trajData = rand(100, 2); % Example 2D trajectory data
%   vol = bmVolumeElement(trajData, 'voronoi_center_out_radial2');
%
% See also:
%   bmVolumeElement_voronoi_center_out_radial2, bmVolumeElement_voronoi_center_out_radial3,
%   bmVolumeElement_voronoi_full_radial2, bmVolumeElement_voronoi_full_radial3,
%   bmVolumeElement_voronoi_full_radial2_nonUnique, bmVolumeElement_voronoi_full_radial3_nonUnique,
%   bmVolumeElement_voronoi_box2, bmVolumeElement_voronoi_box3,
%   bmVolumeElement_imDeformField2, bmVolumeElement_imDeformField3,
%   bmVolumeElement_cartesian2, bmVolumeElement_cartesian3,
%   bmVolumeElement_randomPartialCartesian2_x, bmVolumeElement_randomPartialCartesian3_x,
%   bmVolumeElement_full_radial3, bmVolumeElement_center_out_radial3
%
% Author: Bastien Milani
% Affiliation: CHUV and UNIL, Lausanne - Switzerland
% Date: May 2023

%% Here we should add input sanification on the format of the input and print error messages





%% If the input is a cell array then we assume that it is containing the volume elements themselfs
%% Maybe its better to move this out of here in a second function with a different name
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

%% Ask bastien why the first two volume elements function are different from the others (an need the v = v(:)' ...) => can we uniformly define the format of the bmTraj_whatever functions
%% Would it make sense to make a base class, and inherit it to create your custom bmTraj_whatever?

% Based on the selected trajectory, call the adapt trajectory generation
% function. 
switch argType
    case 'voronoi_box2'
        % the bmTraj_formatTraj is finding points in the center and only
        % consider one in the center. The voronoi fails with duplicates,
        % and therefore you remove them before running the voronoi
        % function, and compute a weigth pretending there was a single
        % center, then we 
        [formatedTraj, ~, formatedIndex, formatedWeight] = bmTraj_formatTraj(t);
        v = bmVolumeElement_voronoi_box2(formatedTraj, N_u, dK_u);
        v = v(:)';
        v = v(1, formatedIndex(:)').*formatedWeight(:)';
        
    case 'voronoi_box3'
        [formatedTraj, ~, formatedIndex, formatedWeight] = bmTraj_formatTraj(t);
        v = bmVolumeElement_voronoi_box3(formatedTraj, N_u, dK_u);
        v = v(:)';
        v = v(1, formatedIndex(:)').*formatedWeight(:)';
        
    case 'voronoi_center_out_radial2'
        v = bmVolumeElement_voronoi_center_out_radial2(t);
        
    case 'voronoi_center_out_radial3'
        v = bmVolumeElement_voronoi_center_out_radial3(t);
        
    case 'voronoi_full_radial2'
        v = bmVolumeElement_voronoi_full_radial2(t);
        
    case 'voronoi_full_radial3'
        v = bmVolumeElement_voronoi_full_radial3(t);
        
    case 'voronoi_full_radial2_nonUnique'
        nAverage = varargin{1};
        v = bmVolumeElement_voronoi_full_radial2_nonUnique(t, nAverage);
        
    case 'voronoi_full_radial3_nonUnique'
        v = bmVolumeElement_voronoi_full_radial3_nonUnique(t);
        
    case 'imDeformField2'
        v = bmVolumeElement_imDeformField2(t, N_u);
        
    case 'imDeformField3'
        v = bmVolumeElement_imDeformField3(t, N_u);
        
    case 'cartesian2'
        v = bmVolumeElement_cartesian2(t);
        
    case 'cartesian3'
        v = bmVolumeElement_cartesian3(t);
        
    case 'randomPartialCartesian2_x'
        v = bmVolumeElement_randomPartialCartesian2_x(t, N_u, dK_u);
        
    case 'randomPartialCartesian3_x'
        v = bmVolumeElement_randomPartialCartesian3_x(t, N_u, dK_u);
        
    case 'full_radial3'
        v = bmVolumeElement_full_radial3(t);
        
    case 'center_out_radial3'
        v = bmVolumeElement_center_out_radial3(t);
        
    otherwise
        % Here we can put a general case function in the future
        error('Trajectory type is unknown: check the possible inputs, or implement you new custom Volume Element function');
end


if sum(isnan(  v(:)  )) > 0
   warning('There is some NaNs in the volume elements !!! You need to replace it. ');  
end

varargout{1} = v; 

end