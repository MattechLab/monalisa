% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% nTask is a natural integer. 
%
% nProcess is a natural integer. 
%
% process_id is an index, therefore must be reduced integer if 'index_mode'
% is 'reduced', and must be a natural integer if 'index_mode' is 'natural'. 
%
% index_mode must be 'reduced' or 'natural'. 

function [num_of_task, index_of_first_task] = bmIntegerEquipartition(nTask, nProcess, process_id, index_mode)

if strcmp(index_mode, 'natural')
    process_id = process_id - 1; % We convert it to reduced integer. 
end

myMod = mod(nTask, nProcess); % This is a reduced_integer in {0, ..., nProcess}. 

L_add = 0; 
if process_id < myMod
    L_add = 1; 
else
    L_add = 0; 
end
num_of_task = fix(nTask/nProcess) + L_add; % This is a natural_integer. 

ind_add = 0; 
if process_id < myMod
    ind_add = 0; 
else
    ind_add = myMod; 
end
index_of_first_task =  num_of_task * process_id + ind_add;  % This is a reduced_index. 

if strcmp(index_mode, 'natural')
    index_of_first_task = index_of_first_task + 1; % We convert it to natural integer. 
end

end

