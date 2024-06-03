% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023


% This function makes the assumbtion that argPhase is distributed in the
% interval [-pi, pi] and that argPhase is not wraped. 

function [a_map, b_map, myFit] = bmAffinePhaseFit(argPhase, argX, varargin)

argSize = size(argPhase); 

myPhase = squeeze(argPhase); 
mySize = size(myPhase); 
mySize = [prod(mySize(1:end-1)) mySize(end)]; 
myPhase = reshape(argPhase, mySize); 

x = squeeze(argX); 
x = reshape(x, [1 length(x)]); 

if mySize(2) == 1
    myPhase =  myPhase';
    mySize = size(myPhase);
end

cPhase = exp(i*myPhase);
myCenterMass = sum(cPhase, 2);
myAngle = angle(myCenterMass);

myAngle_table = repmat(myAngle, [1 mySize(2)]); 

myPhase = mod(myPhase + pi - myAngle_table, 2*pi) - pi;

a_map   = zeros(mySize(1), 1);
b_map   = zeros(mySize(1), 1);

xTable = repmat(x, [mySize(1) 1]);
zTable = myPhase;

MeanX = mean(xTable, 2);
MeanZ = mean(zTable, 2);
MeanX2 = mean(xTable.^2, 2);
MeanXZ = mean(xTable.*zTable, 2);

a_map = (MeanX2.*MeanZ-MeanX.*MeanXZ)./(MeanX2-MeanX.^2); % offset
b_map = (MeanXZ-MeanX.*MeanZ)./(MeanX2-MeanX.^2); % slope

a_map = mod(a_map + pi + myAngle, 2*pi) - pi;

a_map_table = repmat(a_map, [1 length(x)]);
b_map_table = repmat(b_map, [1 length(x)]);

myFit = mod(a_map_table + b_map_table.*xTable + pi, 2*pi)-pi;

if ndims(argPhase) > 2
    a_map = reshape(a_map, argSize(1:end-1));
    b_map = reshape(b_map, argSize(1:end-1));
end

myFit = reshape(myFit, argSize);

end