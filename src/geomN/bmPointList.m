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

        function obj = bmTraj() 
            % Constructor for bmPointList.
            
            
        end 

        
        function point_reshape(obj) 
            % Reshape the points.

            obj.x = reshape(obj.x, [obj.xDim, obj.nPt]); 
            
            % check
            obj.check; 
            
        end 
        
        
        
        function line_reshape(obj) 
            % Reshape the lines.

            obj.x = reshape(obj.x, [obj.xDim, obj.N, obj.nLine]);
            
            % check
            obj.check; 
            
        end 
        
        
        
        
        
        function check(obj) 
            % Check the integrity of the point list.

            


            
        end 
        
                
        
    end 
end 



