% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

%
% argTraj must be p-times-nPt where nPt is the number of positions in p-Dim
% space. argTraj must be a commonTraj. 
%
%
% The output formatedTraj is the same list of positions like argTraj but
% without double points i.e. every position in formatedTraj comes only
% 1 time. But the cener of the trajectory (if it exists) is given as first 
% point in formatedTraj, if the traj goes through the center. If not, 
% then there is no center in the trajectory. 
% But the center must be the only possible place in argTraj 
% with double-points. In other wors, the input argTraj must be a
% commonTraj. 
%
% varargin{1} : As optional argument, the data corresponding to the 
% trajectory can be given. Then, as 1. optional output argument, 
% the formatedData is returned.
%
% varargout{1} : formatedData;
% varargout{2} : formatedIndex; 
% varargout{3} : formatedWeight; 
%
% The output formatedIndex (2. optional output) is a list of indices of
% size [1, nPt] (where nPt is the length of argTraj). 
% Each one of the index in formatedIndex is an index
% position in the second dimension of formatedTraj. The things are defined
% such that argTraj = formatedTraj(:, formatedIndex);
%
% The output formatedWeight (3. optional output) is a list of fractions of
% type 1/(natural number)
% and is of size [1, nPt]. It is one over the number of times that a
% position comes in argTraj.
%
%
% Note: you cannot give input trajectories with SI-projections, they must be
% removed before, because they contain double points. In general, the input 
% trajectory argTraj must be of type commonTraj. 

function [formatedTraj, varargout] = bmTraj_formatTraj(argTraj, varargin)

argTraj = bmPointReshape(argTraj); 

% trivial case ------------------------------------------------------------
if size(argTraj, 2) < 2
    formatedTraj = argTraj;
    if myDataFlag
        varargout{1} = varargin{1};
    end
    varargout{2} = 1;
    varargout{3} = 1;
    return;
end
% end_trivial case --------------------------------------------------------

myEps = 10*eps; % ------------------------------------------------------------- magic number
nPt = size(argTraj, 2);
imDim = size(argTraj, 1); 

myDataFlag = (length(varargin) > 0);
if myDataFlag
    argData = varargin{1};
    argData = bmPointReshape(argData);
end


% constructing formatedTraj and formatedData ----------------------------------
myNorm = zeros(1, nPt); 
for i = 1:imDim
    myNorm = myNorm + argTraj(i, :).^2;
end
myNorm = sqrt(myNorm); 
    
    
myCenterMask    = (myNorm < myEps);
nPointCenter    = sum(myCenterMask(:)); 


if nPointCenter > 0
    myZero       = zeros(size(argTraj, 1), 1);  
    formatedTraj = [myZero, argTraj(:, not(myCenterMask)  )  ];
else
    formatedTraj = argTraj; 
end

if (nargout > 1) && myDataFlag
    
    if nPointCenter > 0
        myCenterData   = mean(  argData(:, myCenterMask)  , 2); 
        formatedData   = [myCenterData, argData(:,   not(myCenterMask)  )];
    else
        formatedData   = argData;
    end
    
    varargout{1} = formatedData;
    
    
elseif nargout > 1
    varargout{1} = []; 
end
% end_constructing formatedTraj and formatedData ------------------------------


% constructing formatedIndex ------------------------------------------------
if nargout > 2

    formatedIndex = zeros(1, nPt);  
    
    if nPointCenter > 0
        myIndex = 1;
    else
        myIndex = 0;
    end
    
    for i = 1:nPt
        if myCenterMask(i) 
            formatedIndex(i) = 1;  
        else
            myIndex = myIndex + 1; 
            formatedIndex(i) = myIndex;
        end
    end
    varargout{2} = formatedIndex; 
    
    testArgTraj = formatedTraj(:, formatedIndex); 
        
    if max(abs(  testArgTraj(:) - argTraj(:)  ))  > myEps
        error('Something went wrong with formatedIndex in ''bmFormatTraj''. ');
        return;
    end
    
    
end
% end_constructing formatedIndex --------------------------------------------




% constructing formatedWeight --------------------------------------------------
if nargout > 3
    formatedWeight = ones(1, nPt);
    if nPointCenter > 0
        formatedWeight(myCenterMask) = 1/nPointCenter;
    end
    varargout{3} = formatedWeight;
end
% end_constructing formatedWeight ----------------------------------------------


end





