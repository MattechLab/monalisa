% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% The output myTraj is p-times-M i.e a list of M points in 
% the p-dimentional real space.  

function myTraj = bmTraj_fullRadial3_phyllotaxis_lineAssym2(varargin)

if length(varargin) == 0
   error('Wrong list of arguments. '); 
   return; 
   
elseif length(varargin) == 1
    
    myMriAcquisParam = varargin{1};
    
    N_n         = myMriAcquisParam.N; 
    nSeg        = myMriAcquisParam.nSeg; 
    nShot       = myMriAcquisParam.nShot; 
    dK_n        = 1/mean(myMriAcquisParam.FoV(:)); 
    
    flagSelfNav = myMriAcquisParam.selfNav_flag;
    nShot_off   = myMriAcquisParam.nShot_off;
    
elseif length(varargin) == 6

    N_n         = varargin{1}; 
    nSeg        = varargin{2}; 
    nShot       = varargin{3}; 
    dK_n        = varargin{4}; 

    flagSelfNav = varargin{5}; 
    nShot_off   = varargin{6}; 
    
end


if fix(N_n/2) ~= N_n/2
   error('N_n must be even in ''bm3DimRadialTraj_phyllotaxis_2'' ! '); 
   return; 
end

[theta, phi] = bmPhyllotaxisAngle3(nSeg, nShot, flagSelfNav);

r = (-0.5 : 1/N_n : 0.5-(1/N_n));
phi     = repmat(phi, [N_n, 1]);
theta   = repmat(theta,[N_n, 1]);
R       = repmat(r',[1, nShot*nSeg]);

x = reshape(R.*cos(phi).*sin(theta), [1, N_n, nSeg, nShot]); 
y = reshape(R.*sin(phi).*sin(theta), [1, N_n, nSeg, nShot]);
z = reshape(R.*cos(theta),           [1, N_n, nSeg, nShot]);

myTraj = cat(1, x, y, z)*N_n*dK_n; 


% if flagSelfNav
%    myTraj(:, :, 1, :) = [];  
% end
% if nShot_off > 0
%    myTraj(:, :, :, 1:nShot_off) = [];  
% end


mySize = size(myTraj); 
mySize = mySize(:)'; 
myTraj = reshape(myTraj, [mySize(1, 1), mySize(1, 2), mySize(1, 3)*mySize(1, 4)]); 


end