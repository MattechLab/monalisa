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
        
        traj_type       = 'void';  
        
        check_flag  = true;  
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        
    end
        
    methods

        % constructor *****************************************************
        function obj = bmMriAcquisitionParam(arg_name) 
            obj.name = arg_name; 
        end 
        % END_constructor *************************************************

        
        
        
        function refresh(obj) % *******************************************
 
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
            
        end % end refresh *************************************************

        
        % save ************************************************************
        function save(obj, reconDir)
           mriAcquisition_node = obj; 
           save([reconDir, '/node/', obj.name, '.mat'], 'mriAcquisition_node');
        end
        % END_save ********************************************************

        
        
        % create **********************************************************
        function create(obj, reconDir)
           temp_load = load([reconDir, '/list.mat']); 
           list = temp_load.list; 
           list.stack(reconDir, obj); 
           list.save(reconDir); 
           obj.save(reconDir); 
        end
        % END_create ******************************************************
        
        
    end % END method
end % END class



