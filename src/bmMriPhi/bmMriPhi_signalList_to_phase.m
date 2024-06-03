% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [single_phase, phase_list] = bmMriPhi_signalList_to_phase(  signal_extracted_list  )

phi = bmMriPhi_signalList_to_phaseList(  signal_extracted_list  ); 

if size(phi, 1) < 2
    phase_list      = phi;
    single_phase    = phi; 
    figure
    plot(single_phase.',    '.-')
    return; 
end

phase_list = zeros(size(phi)); 

phi_0 = phi(1, :); 
c_0 = complex(cos(phi_0), sin(phi_0)); 

phase_list(1 ,:) = phi_0; 

    
for i = 2:size(phi, 1)
   
    c                   = complex(  cos(phi(i, :)),   sin(phi(i, :))  );
    temp_phiDiff        = angle(mean(c./c_0)); 
    cDiff               = complex(  cos(temp_phiDiff),   sin(temp_phiDiff)  );
    phase_list(i, :)    = angle(c/cDiff); 
    
end

myReal          = median(  cos(phase_list), 1  );
myImag          = median(  sin(phase_list), 1  );
single_phase    = angle(complex(myReal, myImag));

figure
plot(phase_list.',      '.-')
figure
plot(single_phase.',    '.-')

end