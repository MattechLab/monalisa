% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% varargin{1} : list of values to be rounded to the closest integer. 
% varargin{2} : if not empty, this is the gridd for rounding i.e. the list
%               of values from varargin{1} are rounded to the closest 
%               element of varargin{2}. 

function out = bmRound(varargin)

if nargin == 1
    out = round(varargin{1}); 
elseif nargin == 2
    myVal = varargin{1}; 
    myValSize = size(myVal); 
    myVal = myVal(:)'; 
    
    myGridd = varargin{2};
    myGriddSize = size(myGridd); 
    myGridd = sort(myGridd(:)); 
    
    n = length(myVal); 
    m = length(myGridd); 
    
    myVal2 = repmat(myVal, [m 1]); 
    myGridd2 = repmat(myGridd, [1 n]); 
    
    myDiff = (myVal2-myGridd2);
    myAbs = abs(myDiff); 
    
    [myMin1 myInd1] = min(myAbs);
    [myMin2 myInd2] = min(flipud(myAbs));
    myInd2 = m-myInd2+1;
    
    myLineInd = myInd1 + [0:n-1]*m; 
    mySign = sign(myVal2(myLineInd));

    myInd = myInd1.*(mySign < 0) + myInd2.*(mySign >= 0); 

    myRound = myGridd(myInd);
    out = reshape(myRound, myValSize); 
    
else
    out = []; 
    return; 
end

end