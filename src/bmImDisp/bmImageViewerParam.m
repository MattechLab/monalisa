% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

classdef bmImageViewerParam < handle
    properties (Access = public)
        
        class_type          = 'bmImageViewerParam';
        
        imDim               = [];
        imSize              = [];
        
        numOfImages         = [];
        curImNum            = [];
        
        numOfImages_4       = [];
        curImNum_4          = [];
        
        numOfImages_5       = [];
        curImNum_5          = [];
        
        permutation         = [];
        
        transpose_flag      = [];
        reverse_flag        = [];
        mirror_flag         = [];
        
        point_A             = [];
        point_B             = [];
        point_C             = [];
        
        psi                 = [];
        theta               = [];
        phi                 = [];
        
        rotation            = [];
        
        colorLimits         = [];
        colorLimits_0       = [];
        
        point_list          = [];
        
    end
    
    properties (SetAccess = private, GetAccess = public)
        
    end
    
    methods
        
        % constructor *****************************************************
        function obj = bmImageViewerParam(argIn, varargin)
            
            argIm           = bmVarargin(varargin);
            obj.imSize      = bmCol(size(argIm))';
            
            if isa(argIn, 'bmImageViewerParam')
                
                obj.imDim               = argIn.imDim;
                obj.imSize              = argIn.imSize;
                
                obj.permutation         = argIn.permutation;
                obj.transpose_flag      = argIn.transpose_flag;
                
                obj.psi                 = argIn.psi;
                obj.theta               = argIn.theta;
                obj.phi                 = argIn.phi;
                
                obj.point_A             = argIn.point_A;
                obj.point_B             = argIn.point_B;
                obj.point_C             = argIn.point_C;
                
                obj.rotation            = argIn.rotation;
                
                obj.reverse_flag        = argIn.reverse_flag;
                obj.mirror_flag         = argIn.mirror_flag;
                
                obj.numOfImages         = argIn.numOfImages;
                obj.curImNum            = argIn.curImNum;
                
                obj.colorLimits         = argIn.colorLimits;
                obj.colorLimits_0       = argIn.colorLimits_0;
                
                obj.numOfImages_4       = argIn.numOfImages_4;
                obj.curImNum_4          = argIn.curImNum_4;
                
                obj.numOfImages_5       = argIn.numOfImages_5;
                obj.curImNum_5          = argIn.curImNum_5;
                
                obj.point_list          = argIn.point_list;
                
            else
                obj.imDim               = size(obj.imSize(:), 1);
                
                obj.permutation         = [];
                
                obj.psi                 = [];
                obj.theta               = [];
                obj.phi                 = [];
                
                obj.point_A             = [];
                obj.point_B             = [];
                obj.point_C             = [];
                
                obj.rotation            = [];
                
                obj.transpose_flag      = false;
                obj.reverse_flag        = false;
                obj.mirror_flag         = false;
                
                obj.numOfImages         = [];
                obj.curImNum            = [];
                
                if (  min(argIm(:)  ) < max(  argIm(:)  )  )
                    obj.colorLimits = [  min(argIm(:)), max(argIm(:))  ];
                else
                    obj.colorLimits = [0, 1];
                end
                obj.colorLimits_0 = obj.colorLimits;
                
                obj.numOfImages_4       = [];
                obj.curImNum_4          = [];
                
                obj.numOfImages_5       = [];
                obj.curImNum_5          = [];
                
                obj.point_list          = [];
                
            end
            
            if argIn == 2
                
                obj.psi                 = 0;
                obj.rotation            = eye(2); 
                
            elseif argIn == 3
                
                obj.permutation         = [1, 2, 3];
                
                obj.psi                 = 0;
                obj.theta               = 0;
                obj.phi                 = 0;
                
                
                obj.rotation            = eye(3);
                
                obj.numOfImages         = obj.imSize(1, 3);
                obj.curImNum            = max(1, fix(  obj.numOfImages/2  ));
                
            elseif argIn == 4
                
                obj.imSize              = obj.imSize(1, 1:3); 
                
                obj.permutation         = [1, 2, 3];
                
                obj.psi                 = 0;
                obj.theta               = 0;
                obj.phi                 = 0;
                
                obj.rotation            = eye(3);
                
                obj.numOfImages         = obj.imSize(1, 3);
                obj.curImNum            = max(1, fix(  obj.numOfImages/2  ));
                
                obj.numOfImages_4       = size(argIm, 4);
                obj.curImNum_4          = 1;
                
                obj.point_list          = cell(obj.numOfImages_4, 1); 
                
            elseif argIn == 5
                
                obj.imSize              = obj.imSize(1, 1:3); 
                
                obj.permutation         = [1, 2, 3];
                
                obj.psi                 = 0;
                obj.theta               = 0;
                obj.phi                 = 0;
                
                obj.rotation            = eye(3);
                
                obj.numOfImages         = obj.imSize(1, 3);
                obj.curImNum            = max(1, fix(  obj.numOfImages/2  ));
                
                obj.numOfImages_4       = size(argIm, 4);
                obj.curImNum_4          = 1;
                
                obj.numOfImages_5       = size(argIm, 5);
                obj.curImNum_5          = 1;
                
                obj.point_list          = cell(obj.numOfImages_4, obj.numOfImages_5); 
                
            end
            
        end
        % END_constructor *************************************************
        
        
    end % END method
end % END class



