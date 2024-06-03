% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% nRank is the total number of index position. It is a natural number.  
%
% ind_curr is the current (input) index. 
%
% index_mode must be 'reduced' or 'natural'. 

function ind_next = bmCircular_ind_next(nRank, ind_curr, index_mode)

if strcmp(index_mode, 'natural')
    ind_curr = ind_curr - 1; % We convert ind_curr to reduced index. 
end



ind_next = mod(ind_curr + 1, nRank);



if strcmp(index_mode, 'natural')
    ind_next = ind_next + 1; % We convert ind_next to natural index. 
end

end