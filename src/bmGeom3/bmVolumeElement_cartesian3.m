% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function v = bmVolumeElement_cartesian3(t)


t = bmPointReshape(t); 
imDim = size(t, 1); 
nPt = size(t, 2); 


if not(imDim == 3)
   error('The trajectory must be 3Dim');
   return; 
end


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







p_c1 = t - repmat(c1, [1, nPt]);
e = (c3 - c1)/norm(c3 - c1); 
s = e'*p_c1; 
s = repmat(s, [imDim, 1]);
myDiff = p_c1 - s.*repmat(e, [1, nPt]); 
mySquareNorm = bmTraj_squaredNorm(myDiff); 
[myMax, myMaxInd] = max(mySquareNorm); 
c5_temp3 = t(:, myMaxInd); 



p_c1 = t - repmat(c1, [1, nPt]);
e = (c4 - c1)/norm(c4 - c1); 
s = e'*p_c1; 
s = repmat(s, [imDim, 1]);
myDiff = p_c1 - s.*repmat(e, [1, nPt]); 
mySquareNorm = bmTraj_squaredNorm(myDiff); 
[myMax, myMaxInd] = max(mySquareNorm); 
c5_temp4 = t(:, myMaxInd); 


e3 = (c3-c1)/norm(c3-c1);
e4 = (c4-c1)/norm(c4-c1);
n = cross(e3, e4); 
d3 = abs(n'*(c5_temp3 - c1)); 
d4 = abs(n'*(c5_temp4 - c1)); 

if d3 < d4 
    c5 = c5_temp4;
    l1 = norm(c3 - c1);
    l2 = norm(c5 - c3);
    
    b1 = (c3 - c1)/l1; 
    b2 = (c5 - c3)/l2; 
else    
    c5 = c5_temp3;
    l1 = norm(c4 - c1);
    l2 = norm(c5 - c4);
    
    b1 = (c4 - c1)/l1; 
    b2 = (c5 - c4)/l2;
end



myDiff = repmat(c5, [1, nPt]) - t; 
mySquareNorm = bmTraj_squaredNorm(myDiff); 
[myMax, myMaxInd] = max(mySquareNorm); 
c6 = t(:, myMaxInd); 


l3 = norm(c6 - c1); 
b3 = (c6 - c1)/l3; 


R = inv([b1(:), b2(:), b3(:)]); 
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

dK = sort(t(3, :)); 
dK = dK(1, 2:end) - dK(1, 1:end-1); 
dK_th = max(dK(:))/3; 
dK_mask = (dK > dK_th);
dK_3 = mean(dK(dK_mask(:))); 

v = dK_1*dK_2*dK_3*ones(1, nPt); 

end