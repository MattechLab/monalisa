% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% There are 2 ways to initialize a witnessInfo : 
% 
% bmWitnessInfo(arg_name, witness_ind); 
% bmWitnessInfo(arg_witnessInfo);
%
% 



classdef bmWitnessInfo < handle
    properties (Access = public)
        
        witness_name            = [];
        
        witness_ind             = [];
        witness_im              = [];
        witness_time            = [];
        
        creationTime            = [];
        finalCallTime           = [];
        finalInd                = [];
        
        param                   = [];
        param_name              = [];
        
    end
    
    
    properties (SetAccess = private, GetAccess = public)
        
    end
    
    
    
    methods
        
        function obj = bmWitnessInfo(varargin) % constructor
            
            myVarargin_1 = [];
            myVarargin_2 = [];
            if length(varargin) > 0
                myVarargin_1 =  varargin{1};
            end
            if length(varargin) > 0
                myVarargin_2 =  varargin{2};
            end
            
            if isa(myVarargin_1, 'bmWitnessInfo')
                
                in_witnessInfo = myVarargin_1;
                
                obj.witness_name            = in_witnessInfo.witness_name;
                
                obj.witness_ind             = in_witnessInfo.witness_ind;
                obj.witness_im              = in_witnessInfo.witness_im;
                obj.witness_time            = in_witnessInfo.witness_time;
                
                obj.creationTime            = in_witnessInfo.creationTime;
                obj.finalCallTime           = in_witnessInfo.finalCallTime;
                obj.finalInd                = in_witnessInfo.finalInd;
                
                obj.param                   = in_witnessInfo.param;
                obj.param_name              = in_witnessInfo.param_name;
                
            else
                
                obj.witness_name    = myVarargin_1;
                
                obj.witness_ind     = myVarargin_2(:)';
                obj.witness_im      = [];
                obj.witness_time    = [];
                
                obj.creationTime    = bmTimeInSecond;
                obj.finalCallTime   = bmTimeInSecond;
                obj.finalInd        = [];
                
                obj.param           = [];
                obj.param_name      = [];
                
            end
            
        end % end constructor *********************************************
        
        
        
        
        function watch(obj, curr_ind, x, n_u, loop_or_final, varargin)
            
            myName = obj.witness_name;
            
            if strcmp(loop_or_final, 'loop')
                
                if curr_ind == 1
                    fprintf([myName, ' : iteration number %d \n'], curr_ind);
                else
                    nCharBack = size(num2str(curr_ind - 1), 2) + 2;
                    fprintf(  repmat('\b', [1, nCharBack])  );
                    fprintf('%d \n', curr_ind);
                end
                
            end
            
            if ~isempty(obj.witness_ind)
                
                n_u = n_u(:)';
                imDim = size(n_u(:), 1);
                temp_im_ind = fix(n_u(1, imDim)/2)+1;
                
                if iscell(x)
                    for i = 1:numel(x)
                        x{i} = bmBlockReshape(x{i}, n_u);
                    end
                else
                    x = bmBlockReshape(x, n_u);
                end
                
                if imDim == 1
                    if iscell(x)
                        temp_im = (x{1});
                    else
                        temp_im = (x);
                    end
                    obj.witness_im = cat(2, obj.witness_im, temp_im);
                    
                elseif imDim == 2
                    if iscell(x)
                        temp_im = (x{1});
                    else
                        temp_im = (x);
                    end
                    temp_im = bmBlockReshape(temp_im, n_u);
                    obj.witness_im = cat(3, obj.witness_im, temp_im);
                    
                elseif imDim == 3
                    
                    if iscell(x)
                        temp_im = (x{1}); 
                    else
                        temp_im = (x); 
                    end
                    
                    temp_im         = bmBlockReshape(temp_im, n_u);
                    temp_im_z       = squeeze(  (temp_im(:, :, temp_im_ind))  );
                    % temp_im_y       = squeeze(  (temp_im(:, temp_im_ind, :))  );
                    % temp_im_x       = squeeze(  (temp_im(temp_im_ind, :, :))  );
                    % temp_im         = cat(2, temp_im_x, temp_im_y, temp_im_z);
                    temp_im         = temp_im_z;
                    
                    obj.witness_im  = cat(3, obj.witness_im, temp_im);
                    
                end
                
                obj.witness_time    = cat(2, obj.witness_time, bmTimeInSecond);
                obj.finalCallTime   = bmTimeInSecond;
                obj.finalInd        = curr_ind;
                witnessInfo         = obj;
                save(['wit_',   myName], 'witnessInfo',   '-v7.3');
                
                if ismember(curr_ind, obj.witness_ind)
                    
                    if iscell(x)
                        for i = 1:numel(x)
                            x{i} = bmBlockReshape(x{i}, n_u);
                        end
                    else
                        x = bmBlockReshape(x, n_u);
                    end
                    
                    save(['x_',     myName], 'x',             '-v7.3');
                    
                    
                    if numel(varargin) > 0
                        if ~isempty(varargin{1})
                            z = varargin{1};
                            save(['z_', myName], 'z', '-v7.3');
                        end
                    end
                    
                    
                    if numel(varargin) > 1
                        if ~isempty(varargin{2})
                            u = varargin{2};
                            save(['u_', myName], 'u', '-v7.3');
                        end
                    end
                    
                end
                
                if strcmp(loop_or_final, 'final')
                    disp([myName, ' completed. ']);
                end
                
                
            end % END_witness_ind non_empty        
            
        end % END_function
        
    end % END method
end % END class



