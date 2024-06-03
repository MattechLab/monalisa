% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


% p_mean is the average of the point list.
% n is the normed-eigenvector of the largest eigen-value of the inertial-
% ellipsiod-tensor of the point masses (all equal masses) located on 
% the point list. 


function myPlane = bmQuickFitPlane(point_list, varargin)

display_flag = bmVarargin(varargin); 
if isempty(display_flag)
    display_flag = true; 
end
    
p_list  = bmPointReshape(point_list); 
nPt     = size(p_list, 2); 
if size(p_list, 1) == 1
   p_list = p_list'; 
   nPt = 1; 
end
if nPt == 1
    p_list = cat(2, p_list, p_list); 
    nPt = 2; 
end


p_mean  = mean(p_list, 2); 
original_p_list = p_list; 

p_list = p_list - repmat(p_mean, [1, nPt]); 

x = p_list(1, :); 
y = p_list(2, :);
z = p_list(3, :);

Ixx = sum(y(:).^2 + z(:).^2); 
Iyy = sum(x(:).^2 + z(:).^2); 
Izz = sum(x(:).^2 + y(:).^2); 

Ixy = -sum(x(:).*y(:));
Ixz = -sum(x(:).*z(:));
Iyz = -sum(y(:).*z(:));

I = [   Ixx, Ixy, Ixz; 
        Ixy, Iyy, Iyz; 
        Ixz, Iyz, Izz]; 

[v, ev] = eig(I); 

ev = [ev(1, 1), ev(2, 2), ev(3, 3)]; 
[myVal, myInd] = max(ev); 

n = v(:, myInd); 
n = n/norm(n); 

myPlane     = bmPlane3; 
myPlane.p   = p_mean; 
myPlane.n   = n; 

% plot --------------------------------------------------------------------

if display_flag
    
    % plot_param
    nPt_gridd = 100;
    
    temp_norm = sqrt(  p_list(1, :).^2 + p_list(2, :).^2 + p_list(3, :).^2  );
    temp_norm = max(temp_norm);
    
    figure
    hold on
    axis image
    plot3(original_p_list(1, :), original_p_list(2, :), original_p_list(3, :), 'r.');
    
    [X, Y] = ndgrid(-nPt_gridd/2:nPt_gridd/2-1, -nPt_gridd/2:nPt_gridd/2-1);
    X = 2*X/nPt_gridd;
    Y = 2*Y/nPt_gridd;
    
    nx = size(X, 1);
    ny = size(X, 2);
    
    X = repmat(X(:)'*temp_norm, [3, 1]);
    Y = repmat(Y(:)'*temp_norm, [3, 1]);
    
    v1 = repmat(v(:, 1), [1, size(X, 2)]);
    v2 = repmat(v(:, 2), [1, size(Y, 2)]);
    
    g = repmat(p_mean, [1, size(X, 2)]) + v1.*X + v2.*Y;
    g = permute(g, [2, 3, 1]);
    g = reshape(g, [nx, ny, 3]);
    
    mesh(g(:, :, 1), g(:, :, 2), g(:, :, 3));
    
end

% END_plot ----------------------------------------------------------------

end

