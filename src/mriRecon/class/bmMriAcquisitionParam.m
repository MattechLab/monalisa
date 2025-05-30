% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

classdef bmMriAcquisitionParam < handle
    properties (Access = public)

        class_type      = 'bmMriAcquisitionParam'; 
        node_type       = 'mriAcquisition_node'; 
        
        name            = 'void'; 
        mainFile_name   = 'void';
        pulseqTrajFile_name   = 'void';
        
        imDim           = double([]);
        N               = double([]); 
        nSeg            = double([]);
        nShot           = double([]);
        nPar            = double([]);
        nLine           = double([]);
        nPt             = double([]);
        nCh             = double([]);
        nEcho           = double([]);
        raw_N_u         = double([]);
        raw_dK_u        = double([]);
        
        selfNav_flag    = logical([]);
        nShot_off       = double([]); 
        roosk_flag      = logical([]); 
        
        FoV             = double([]); 
        
        timestamp       = double([]); 
        traj_type       = 'void';  
        
        check_flag  = true;  
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        
    end
        
    methods

        function obj = bmMriAcquisitionParam(arg_name) 
            % Constructor for bmMriAcquisitionParam.
            obj.name = arg_name; 
        end 

        function refresh(obj)
            % Refresh the acquisition parameters.
            if isempty(obj.N)
                obj.N = single(obj.nPt/obj.nLine); 
            end
            if isempty(obj.nSeg)
                obj.nSeg = single(obj.nLine/obj.nShot); 
            end
            if isempty(obj.nShot)
                obj.nShot = single(obj.nLine/obj.nSeg); 
            end
            if isempty(obj.nLine)
                obj.nLine = single(obj.nSeg*obj.nShot); 
            end
            if isempty(obj.nPt)
                obj.nPt = single(obj.N*obj.nSeg*obj.nShot); 
            end
            
        end

        function save(obj, reconDir)
            % Save the acquisition parameters to a file.
            mriAcquisition_node = obj; 
            save([reconDir, '/node/', obj.name, '.mat'], 'mriAcquisition_node');
        end

        function create(obj, reconDir)
            % Create a new acquisition parameter set.
            temp_load = load([reconDir, '/list.mat']); 
            list = temp_load.list; 
            list.stack(reconDir, obj); 
            list.save(reconDir); 
            obj.save(reconDir); 
        end
        
    end % END method
end % END class



