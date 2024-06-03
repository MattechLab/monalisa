% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [s_lowPass, s_bandPass] = bmMriPhi_signal_selection(   s, ...
                                                                t_ref, ...
                                                                nu_ref, ...
                                                                lowPass_filter, ...
                                                                bandPass_filter, ...
                                                                nSignal_to_select )


lowPass_filter  = repmat(lowPass_filter,    [size(s, 1), 1]); 
bandPass_filter = repmat(bandPass_filter,   [size(s, 1), 1]); 

nSignal             = size(s,1); 
nSignal_to_select   = min([nSignal, nSignal_to_select]); 

Fs = bmDFT(s, t_ref, [], 2, 2);
s_lowPass       = real(bmIDF(lowPass_filter.*Fs,   nu_ref, [], 2, 2));
s_bandPass      = real(bmIDF(bandPass_filter.*Fs,  nu_ref, [], 2, 2));

myDiff      = abs(s_lowPass - s); 
myStd       = zeros(nSignal, 1); 
for i = 1:nSignal
    myStd(i, 1) = std(myDiff(i, :)); 
end
myRms       = sqrt(mean(abs(s_bandPass).^2, 2));  
myScore     = myStd./myRms; 

[~, myPerm] = sort(  myScore(:)  ); 

s_lowPass   = s_lowPass(  myPerm(:), :  ); 
s_lowPass   = s_lowPass(  1:nSignal_to_select, :); 

s_bandPass   = s_bandPass(  myPerm(:), :  ); 
s_bandPass   = s_bandPass(1:nSignal_to_select, :); 


end