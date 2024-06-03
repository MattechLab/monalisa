% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

classdef bmConvergeCondition < handle
    properties (Access = public)
        
        nIter_max               = 500; 
        targDist_th             = 1e-4; 
        targProgression_th      = 1e-4; 
        y_travel_th             = 1e-4;
        x_travel_th             = 1e-4; 
        
        nIter_curr              = 0; 
        targDist_curr           = []; 
        targProgression_curr    = [];
        y_travel_curr           = [];
        x_travel_curr           = [];
        
        
        nIter_statu              = true; 
        targDist_statu           = true; 
        targProgression_statu    = true;
        y_travel_statu           = true;
        x_travel_statu           = true;
        
        
        
        targDist_prev           = []; 
        targProgression_flag    = true; 
        
        targDist_history        = []; 
        targProgression_hisotry = [];
        y_travel_history        = [];
        x_travel_history        = [];
        
        
        min_denom               = 1e-5; 

        startTime               = []; 
        endTime                 = []; 
        
    end
    
    
    properties (SetAccess = private, GetAccess = public)
        
    end
    
    
    
    methods

        function obj = bmConvergeCondition(varargin) % constructor

            myVarargin_1 = [];
            if length(varargin) > 0
               myVarargin_1 =  varargin{1}; 
            end
            
            if isa(myVarargin_1, 'bmConvergeCondition')
                in_convCond = myVarargin_1;
                
                obj.nIter_max               = in_convCond.nIter_max;
                obj.targDist_th             = in_convCond.targDist_th;
                obj.targProgression_th      = in_convCond.targProgression_th;
                obj.y_travel_th             = in_convCond.y_travel_th;
                obj.x_travel_th             = in_convCond.x_travel_th;
                obj.nIter_curr              = in_convCond.nIter_curr;
                obj.targDist_curr           = in_convCond.targDist_curr;
                obj.targProgression_curr    = in_convCond.targProgression_curr;
                obj.y_travel_curr           = in_convCond.y_travel_curr;
                obj.x_travel_curr           = in_convCond.x_travel_curr;
                obj.nIter_statu             = in_convCond.nIter_statu;
                obj.targDist_statu          = in_convCond.targDist_statu;
                obj.targProgression_statu   = in_convCond.targProgression_statu;
                obj.y_travel_statu          = in_convCond.y_travel_statu;
                obj.x_travel_statu          = in_convCond.x_travel_statu;
                obj.targDist_prev           = in_convCond.targDist_prev;
                obj.targProgression_flag    = in_convCond.targProgression_flag;
                obj.targDist_history        = in_convCond.targDist_history;
                obj.targProgression_hisotry = in_convCond.targProgression_hisotry;
                obj.y_travel_history        = in_convCond.y_travel_history;
                obj.x_travel_history        = in_convCond.x_travel_history;
                obj.min_denom               = in_convCond.min_denom;
                obj.startTime               = in_convCond.startTime;
                obj.endTime                 = in_convCond.endTime;
                
            else
                [arg_nIter_max,...
                 arg_targDist_th,...
                 arg_targProgression_th,...
                 arg_y_travel_th,...
                 arg_x_travel_th,...
                 arg_min_denom,...
                 arg_targProgression_flag] = bmVarargin(varargin);
                
                if not(isempty(arg_nIter_max))
                    obj.nIter_max       = arg_nIter_max;
                end
                
                if not(isempty(arg_targDist_th))
                    obj.targDist_th     = arg_targDist_th;
                end
                
                if not(isempty(arg_targProgression_th))
                    obj.targProgression_th  = arg_targProgression_th;
                end
                
                if not(isempty(arg_y_travel_th))
                    obj.y_travel_th  = arg_y_travel_th;
                end
                
                if not(isempty(arg_x_travel_th))
                    obj.x_travel_th  = arg_x_travel_th;
                end
                
                if not(isempty(arg_min_denom))
                    obj.min_denom  = arg_min_denom;
                end
                
                if not(isempty(arg_targProgression_flag))
                    obj.targProgression_flag  = arg_targProgression_flag;
                end
            end
            
        end % end constructor *********************************************


        function myCondition = check(obj, varargin) 
            
            [arg_targDist_curr, arg_y_travel_curr, arg_x_travel_curr] = bmVarargin(varargin); 
            
            if obj.nIter_curr == 0
               obj.startTime = datetime;  
            end
            obj.nIter_curr = obj.nIter_curr + 1; 
            
            if not(isempty(arg_targDist_curr))
                obj.targDist_prev = obj.targDist_curr; 
                obj.targDist_curr = abs(arg_targDist_curr);
                obj.targDist_history = cat(2, obj.targDist_history, obj.targDist_curr);
            end
            
            if not(isempty(arg_targDist_curr)) && not(isempty(obj.targDist_prev)) && obj.targProgression_flag
                a = abs(arg_targDist_curr); 
                b = abs(obj.targDist_prev); 
                obj.targProgression_curr = abs(a - b); 
                obj.targProgression_hisotry = cat(2, obj.targProgression_hisotry, obj.targProgression_curr); 
                
            end
            
            if not(isempty(arg_y_travel_curr))
                obj.y_travel_curr = abs(arg_y_travel_curr);
                obj.y_travel_history = cat(2, obj.y_travel_history, obj.y_travel_curr); 
            end
            
            if not(isempty(arg_x_travel_curr))
                obj.x_travel_curr = abs(arg_x_travel_curr); 
                obj.x_travel_history = cat(2, obj.x_travel_history, obj.x_travel_curr); 
            end
            
            
            
            
            
            if not(isempty(obj.nIter_curr))
                obj.nIter_statu = (obj.nIter_curr <= obj.nIter_max);
            end
            if not(isempty(obj.targDist_curr))
                obj.targDist_statu = (obj.targDist_curr > obj.targDist_th);  
            end
            if not(isempty(obj.targProgression_curr))
                obj.targProgression_statu = (obj.targProgression_curr > obj.targProgression_th);
            end
            if not(isempty(obj.y_travel_curr))
                obj.y_travel_statu = (obj.y_travel_curr > obj.y_travel_th);
            end
            if not(isempty(obj.x_travel_curr))
                obj.x_travel_statu = (obj.x_travel_curr > obj.x_travel_th);
            end
            
            
            myCondition   = obj.nIter_statu && obj.targDist_statu && obj.targProgression_statu && obj.y_travel_statu && obj.x_travel_statu;
            if not(myCondition)
                obj.endTime = datetime;
                if obj.nIter_curr == (obj.nIter_max + 1)
                    obj.nIter_curr = obj.nIter_curr - 1;
                end
            end
            
        end 
    
        
        function disp_info(obj, varargin) 
            
            arg_string = bmVarargin(varargin); 
            
            fprintf('\n');
            
            if not(isempty(arg_string))
                fprintf('%s \n', arg_string);
            end
            if not(isempty(obj.nIter_curr))
                fprintf('nIter                  : %d . \n', obj.nIter_curr);
            end
            if not(isempty(obj.targDist_curr))
                fprintf('targDist_curr          : %d . \n', obj.targDist_curr);
            end
            if not(isempty(obj.targProgression_curr))
                fprintf('targProgression_curr   : %d . \n', obj.targProgression_curr);
            end
            if not(isempty(obj.y_travel_curr))
                fprintf('y_travel_curr          : %d . \n', obj.y_travel_curr);
            end
            if not(isempty(obj.x_travel_curr))
                fprintf('x_travel_curr          : %d . \n', obj.x_travel_curr);
            end
            
        end 
    

        function plot(obj) 
            
            if not(isempty(obj.targDist_history))
                figure
                hold on
                plot(obj.targDist_history, '.-'); 
                title('targDist\_history')
            end
            if not(isempty(obj.targProgression_hisotry))
                figure
                hold on
                plot(obj.targProgression_hisotry, '.-'); 
                title('targProgression\_history')
            end
            if not(isempty(obj.y_travel_history))
                figure
                hold on
                plot(obj.y_travel_history, '.-');
                title('y\_travel\_history')
            end
            if not(isempty(obj.x_travel_history))
                figure
                hold on
                plot(obj.x_travel_history, '.-');
                title('x\_travel\_history')
            end
        end 

                
        
    end % END method
end % END class



