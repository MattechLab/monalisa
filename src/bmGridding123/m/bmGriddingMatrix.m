% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

classdef bmGriddingMatrix < handle
    
    % public_properties ---------------------------------------------------
    properties (Access = public)
        
        % All lists must be line vectors, not column. That means that their size
        % must be of the form [1, length(list)].
        
        % All sizes must be int32 excepted secrete_length which is int64. 
        % All floating point values must be single precision.
        
        
        u_ind   = int32([]);    % List of index-jumps in the pillar_values array. Vector.
        w       = single([]);   % Gridding weights i.e. entries of the gridding matrix. Vector. 
        
        nPt     = int32([]);    % Number of points in the arbitrary gridd. Scalar. 
        Nx      = int32([]);    % Size x of the pillar gridd. Is non-zero for imDim > 0. Scalar. 
        Ny      = int32([]);    % Size y of the pillar gridd. Is non-zero for imDim > 1. Scalar.
        Nz      = int32([]);    % Size z of the pillar gridd. Is non-zero for imDim > 2. Scalar.
        
        secrete_length      = int64([]); % int64 !!!
        
        
        
        
        % information_param -----------------------------------------------
        %
        % Just for keeping track of how the matrix was constructed. 
        % These parameters have no funcitonal role and can be left empty. 
        
        N_u                 = int32([]);
        d_u                 = single([]);
        kernel_type         = 'void';
        nWin                = int32([]);
        kernelParam         = single([]);
        
        gridding_type      = 'void';
        
        % END_information_param -------------------------------------------
        
    end
    % END_public_properties -----------------------------------------------
    
    % private_properties
    properties (SetAccess = private, GetAccess = public)
        
    end
    % END_private_properties
    
    
    
    % public_method
    methods
        
    end
    % END_public_method
    
end % END class



