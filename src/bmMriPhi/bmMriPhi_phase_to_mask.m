% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myMask = bmMriPhi_phase_to_mask(phi, nPhase, argPercent)

phi = phi(:).'; 
nPt = size(phi(:), 1); 

c = [0:nPhase-1]/nPhase;
w = argPercent*2*pi/nPhase/2; 

psi = complex(cos(phi),    sin(phi)   ); 
c   = complex(cos(c*2*pi), sin(c*2*pi)); 
c = repmat(c(:), [1, nPt]); 

myMask  = false(nPhase, nPt); 
for i   = 1:nPhase
    myMask(i, :) = abs(angle(psi./c(i, :))) <= w; 
end



figure
hold on
t = 1:size(phi, 2); 
for i = 1:nPhase
    temp_mask   = myMask(i, :); 
    temp_t      = t(1, temp_mask); 
    temp_phi    = phi(1, temp_mask); 
    plot(temp_t, temp_phi, '.'); 
end

end