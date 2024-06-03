% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function s_out = bmMriPhi_manually_exclude_signal_of_list(s_in)

myList = [];
for i = 1:size(s_in, 1)
    figure
    hold on
    plot(s_in(1, :), '.-');
    plot(s_in(i, :), '.-');
    uiwait;
    
    if bmYesNo
        myList = cat(1, myList, i);
    end
end

s_out = s_in(myList(:), :); 


end