% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function v = bmVolumeElement_cartesian2(t)

if not(size(t, 1) == 2)
   error('The trajectory must be 2Dim');
   return; 
end


t = bmPointReshape(t); 
imDim = size(t, 1); 
nPt = size(t, 2); 


myDiff = repmat(t(:, 1), [1, nPt]) - t; 

mySquareNorm = bmTraj_squaredNorm(myDiff); 
[myMax, myMaxInd] = max(mySquareNorm); 
c1 = t(:, myMaxInd); 


myDiff = repmat(c1, [1, nPt]) - t; 
mySquareNorm = bmTraj_squaredNorm(myDiff); 
[myMax, myMaxInd] = max(mySquareNorm); 
c2 = t(:, myMaxInd); 


p_c1 = t - repmat(c1, [1, nPt]);
e = (c2 - c1)/norm(c2 - c1); 
s = e'*p_c1; 
s = repmat(s, [imDim, 1]);
myDiff = p_c1 - s.*repmat(e, [1, nPt]); 
mySquareNorm = bmTraj_squaredNorm(myDiff); 
[myMax, myMaxInd] = max(mySquareNorm); 
c3 = t(:, myMaxInd); 


myDiff = repmat(c3, [1, nPt]) - t; 
mySquareNorm = bmTraj_squaredNorm(myDiff); 
[myMax, myMaxInd] = max(mySquareNorm); 
c4 = t(:, myMaxInd); 






l3 = norm(c3 - c1); 
b3 = (c3 - c1)/l3; 

l4 = norm(c4 - c1); 
b4 = (c4 - c1)/l4; 


R = inv([b3(:), b4(:)]); 
t = R*t; 


dK = sort(t(1, :)); 
dK = dK(1, 2:end) - dK(1, 1:end-1); 
dK_th = max(dK(:))/3; 
dK_mask = (dK > dK_th);
dK_1 = mean(dK(dK_mask(:))); 

dK = sort(t(2, :)); 
dK = dK(1, 2:end) - dK(1, 1:end-1); 
dK_th = max(dK(:))/3; 
dK_mask = (dK > dK_th);
dK_2 = mean(dK(dK_mask(:))); 


v = dK_1*dK_2*ones(1, nPt); 

end