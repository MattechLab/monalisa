% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023
% 
% This fucntion was written based on the code of 
%
% Davide Piccini
%
% More information can be found in
%
% "Spiral phyllotaxis: the natural way to 
% construct a 3D radial trajectory in MRI", 
% MRM 2011. 




% This spiral covers the north hemisphere only.

function [theta, phi] = bm3DimPhyllotaxisAngle(nseg, nshot, varargin)

goldNum     = (1 + sqrt(5))/2;
goldAngle   = 2*pi - (2*pi / goldNum);

flagSelfNav = 0;
if length(varargin) > 0
    flagSelfNav = varargin{1};
end

nseg_tot = nseg*nshot;
if flagSelfNav
    nseg_pure = nseg_tot - nshot;
else
    nseg_pure = nseg_tot;
end

q = pi/(2*sqrt(nseg_pure)); 


phi     = zeros(1, nseg_tot);
theta   = zeros(1, nseg_tot);


myCounter = 1;

for i = 1:nseg
    for j = 1:nshot
        myIndex = (i-1) + (j-1) * nseg  + 1;
        if flagSelfNav && (i == 1)
            phi(myIndex) = 0;
            theta(myIndex) = 0;
        else
            phi(myIndex) = mod(myCounter*goldAngle, (2*pi));
            theta(myIndex) = q*sqrt(myCounter);
            myCounter = myCounter + 1;
        end
    end
end


end