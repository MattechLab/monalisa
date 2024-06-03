% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

classdef bmImReg_affineTransform < handle
    properties (Access = public)

        class_type      = 'bmImReg_affineTransform'; 
        
        t       = single([]);
        c_ref   = single([]); 
        R       = single([]);
        S       = single([]);
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        
    end
        
        
end % END class



