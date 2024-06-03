% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

classdef bmPointList < handle
    properties (Access = public)
        
        % lists
        x       = double([]); 
        ve      = double([]); 
        f       = double([]); 
        v       = double([]); 
        
        
        % sizes
        x_dim   = double([]); 
        f_dim   = double([]); 
        v_dim   = double([]); 
        
        nPt     = double([]); 
        N       = double([]); 
        nLine   = double([]); 
        nSeg    = double([]);
        nShot   = double([]);
        
        % cartesian gridd
        N_u     = double([]);
        d_u     = double([]); 
        
        % types
        x_type      = 'void';
        ve_type     = 'void'; 
        f_type      = 'void'; 
        v_type      = 'void';
        check_flag  = true;  
        
    end
    
    
    properties (SetAccess = private, GetAccess = public)
        
    end
    
    
    
    methods

        function obj = bmTraj() % constructor 
            
            
        end % end constructor *********************************************

        
        function point_reshape(obj) % *************************************
 
            obj.x = reshape(obj.x, [obj.xDim, obj.nPt]); 
            
            % check
            obj.check; 
            
        end % end point_reshape *******************************************
        
        
        
        function line_reshape(obj) % **************************************

            obj.x = reshape(obj.x, [obj.xDim, obj.N, obj.nLine]);
            
            % check
            obj.check; 
            
        end % end point_reshape *******************************************
        
        
        
        
        
        function check(obj) % *********************************************
           
            

            
        end % END check function ******************************************
        
                
        
    end % END method
end % END class



