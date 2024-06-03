% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% x must be of size [imDim, nPt], where imDim = 1 or 2 or 3. 

function out = bmConvexFaceArea(x, sort_on)

nPt = size(x, 2);

if size(x, 1) == 1
    out = 0; 
    return; 
elseif size(x, 1) == 2
    x = cat(1, x, zeros(1, nPt));
end

 

x0      = mean(x, 2);
v       = x - repmat(x0, [1, nPt]);

if sort_on
    v1      = repmat(v(:, 1), [1, nPt]);
    c       = cross(v1, v);
    c_norm = sqrt(c(1, :).^2 + c(2, :).^2 + c(3, :).^2);
    [~, ind_max] = max(c_norm);
    e3 = c(:, ind_max);         e3 = e3/norm(e3);
    e1 = v(:, ind_max);         e1 = e1/norm(e1);
    e1_rep = repmat(e1, [1, nPt]); 
    
    myCos = e1'*v;
    mySin = e3'*cross(e1_rep, v);
    
    myPhase = angle(complex(myCos, mySin));
    [~, myPerm] = sort(myPhase);
    v = v(:, myPerm);
end


z = circshift(v, [0, -1]);
out = norm(sum(cross(v, z), 2))/2;

end