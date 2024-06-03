% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% This function counts the number of straight line segments containing 
% three or more points. If two points are "too" far away, they are 
% considered as lying in different segments (see the code). Non-separated
% points are considered as out of straight segments and they break straight
% segments. 
%
% varargin{1} : N
% varargin{2} : inN_integer
% varargin{3} : dK_list

function [nLine, varargout] = bmTraj_nLine(argTraj)

    argTraj = bmPointReshape(argTraj); 

    th_n1 = 3.5; % -------------------------------------------------------------- magic number 
    th_n_de = 1/1000; % --------------------------------------------------------- magic number
    myEps = 10*eps; % ----------------------------------------------------------- magic number 
    delta_separation = myEps/(th_n_de/1000); % ---------------------------------- magic number 
    
    imDim   = size(argTraj, 1); 
    nPt     = size(argTraj, 2); 
    
    
    
    % jump_mask ---------------------------------------------------------
    d1 = argTraj(:, 2:nPt) - argTraj(:, 1:nPt-1); 
    d1 = [zeros(imDim, 1), d1]; 
    n1 = zeros(1, nPt); 
    for i = 1:imDim
       n1 = n1 + d1(i, :).^2;  
    end
    n1 = sqrt(n1);
    n1(1, 1) = 0; 
    jump_mask = ( n1(:)' > th_n1*median(n1(:)) );
    % END_jump_mask -----------------------------------------------------
    
    
    
    
    
    % nonSeparated_mask ---------------------------------------------------
    nonSeparated_mask = (n1 <= delta_separation); 
    n1(1, nonSeparated_mask) = 1;
    for i =1:imDim
        d1(i, nonSeparated_mask) = 0;
    end    
    nonSeparated_mask = nonSeparated_mask | circshift(nonSeparated_mask, [0, -1]); 
    % END_nonSeparated_mask -----------------------------------------------
    
    
    
    
    
    % dirChangeMask -------------------------------------------------------
    e  = d1./repmat(n1, [imDim, 1]);        
    de = e(:, 2:nPt) - e(:, 1:nPt-1);
    de(:, 1) = zeros(imDim, 1); 
    de = [de, zeros(imDim, 1)];   
    n_de = zeros(1, nPt); 
    for i = 1:imDim
       n_de = n_de + de(i, :).^2;  
    end
    n_de = sqrt(n_de);
    dirChange_mask = (n_de > th_n_de);
    % END_dirChangeMask ---------------------------------------------------
    
    
    
    
    % outOfLine_mask ------------------------------------------------------
    outOfLine_mask = (jump_mask | dirChange_mask | nonSeparated_mask); 
    % END_outOfLine_mask --------------------------------------------------
    
    
    
    % counting ------------------------------------------------------------
    nLine = 0;
    lastMaskVal = true;
    dK_list = zeros(1, nPt);
    dK_count = 0;
    for i = 2:nPt;
        currentMaskVal = outOfLine_mask(1, i); 
        
        if not(currentMaskVal)
            if lastMaskVal
                nLine = nLine + 1;
            end
            
            dK_count = dK_count + 1;
            dK_list(1, dK_count) = n1(1, i); 
        end
        
        lastMaskVal = currentMaskVal;
    end
    
    
    dK_list = dK_list(1, 1:dK_count); 
    
%     dK_median = median(dK_list); 
%     dK_list(dK_list >   2*dK_median) = []; 
%     dK_list(dK_list < 0.5*dK_median) = [];
%     dK = median(dK_list); 
    
    N = nPt/nLine;
    isN_integer     = not(  abs(N - round(N))>0  );
    % END_counting --------------------------------------------------------
    
    
    
    % varargout -----------------------------------------------------------
    if nargout > 1
        varargout{1} = N;  
    end
    if nargout > 2
        varargout{2} = isN_integer;
    end
    if nargout > 3         
        varargout{3} = dK_list;
    end
    % END_varargout -------------------------------------------------------
    

end