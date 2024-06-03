% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmGauss(x, mySigma, varargin)

myMean = []; 
if length(varargin) > 0
    myMean = varargin{1}; 
end
if isempty(myMean)
    myMean = 0; 
end

y = normpdf(x, myMean, mySigma); 

end