% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function t = bmTimeInSecond()

d = datetime; 
t = d.Second + d.Minute*60 + d.Hour*60^2 + d.Day*24*60^2; 

end