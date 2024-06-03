% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


function out = bmVolumeElement1(x)

if (size(x, 1) == 1) || (size(x, 2) == 1)
   x = x(:);  
end

% we sort x after its first line. 
[~, myPerm]     = sort(x(:, 1));
[~, myInvPerm]  = sort(myPerm);
mySort = x(myPerm, :);

% We compute the volume elements. 
myMid = (mySort(2:end, :) + mySort(1:end-1, :))/2;
myMid = [mySort(1, :) - (myMid(1, :) - mySort(1, :)); myMid; mySort(end, :) + (mySort(end, :) - myMid(end, :))];
myDiff = myMid(2:end, :) - myMid(1:end-1, :);
out = myDiff(myInvPerm, :);

end