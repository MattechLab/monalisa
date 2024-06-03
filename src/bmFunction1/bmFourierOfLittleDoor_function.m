% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function Ff = bmFourierOfLittleDoor_function(k, L, a)

Ff = bmSinc(L*pi*k).*exp(-i1*2*pi*a*k)

end