% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% The traj t must have the size [imDim, N, nLine]

function e = bmTraj_lineDirection(t)

imDim = size(t, 1); 
N = size(t, 2); 
nLine = size(t, 3); 

t1 = repmat(t(:, 1, :), [1, N, 1]);

e = t - t1;
e = e(:, ceil(N/2):end, :); 
e_norm = zeros(1, size(e, 2), size(e, 3)); 
for i = 1:imDim
    e_norm = e_norm + e(i, :, :).^2;
end
e_norm = sqrt(e_norm); 
e_norm = repmat(e_norm, [imDim, 1, 1]); 
e = e./e_norm; 
e = squeeze(mean(e, 2)); 


end