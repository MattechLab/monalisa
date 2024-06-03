% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


function myTraj = bmTraj_fullRadial2_lineAssym2(N, nSeg, dK_n)


kMax = N*dK_n/2; 
lineAssym = 2;

if lineAssym == 0
    myShift = 0;
elseif lineAssym == 1
    myShift = 1;
elseif lineAssym == 2
    myShift = 0;
end

phi = linspace(0, 2*pi, nSeg+1);
phi = phi(1:end-1);

r = 0:N-1;
r = r - fix(N/2) + myShift;
r = r*kMax/fix(N/2);

myTraj    = zeros(N, nSeg, 2);

myTraj(:,:,1) = r'*cos(phi);
myTraj(:,:,2) = r'*sin(phi);

myTraj = reshape(myTraj, [N*nSeg, 2]);
myTraj = myTraj';

end