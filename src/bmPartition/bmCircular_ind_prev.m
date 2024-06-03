% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% nRank is the total number of index position. It is a natural number.  
%
% ind_curr is the current (input) index. 
%
% index_mode must be 'reduced' or 'natural'. 

function ind_prev = bmCircular_ind_prev(nRank, ind_curr, index_mode)

if strcmp(index_mode, 'natural')
    ind_curr = ind_curr - 1; % We convert ind_curr to reduced index. 
end



ind_prev = mod(ind_curr - 1 + nRank, nRank); % Here is ind_prev a reduced index. 



if strcmp(index_mode, 'natural')
    ind_prev = ind_prev + 1; % We convert ind_prev to natural index. 
end

end