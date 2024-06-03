% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [a_map b_map varargout] = bmAffineFit(argImagesTable, argX, varargin)

    mySize = size(argImagesTable);
    mySize = [prod(mySize(1:end-1)) mySize(end)]; 
    
    if not(length(argX) == mySize(2))
        a_map = 0; 
        b_map = 0; 
        errordlg('Wrong list of arguments'); 
        return;  
    end

    errorTh = [];
    lowerBound = [];
    upperBound = []; 
    
    if length(varargin) == 0
        1+1;
    elseif length(varargin) == 1
        errorTh = varargin{1}; 
    elseif length(varargin) == 3 
        errorTh = varargin{1}; 
        lowerBound = varargin{2}; 
        upperBound = varargin{3}; 
    else
        a_map = 0; 
        b_map = 0; 
        errordlg('Wrong list of arguments'); 
        return;
    end

    imagesTable = reshape(argImagesTable, mySize); 
    iMax = mySize(2); 
    x = squeeze(argX)'; 

    a_map   = zeros(mySize(1), 1);
    b_map   = zeros(mySize(1), 1);

    
    xTable = reshape(x, [1 length(x)]); 
    xTable = repmat(xTable, [mySize(1) 1]); 
    zTable = imagesTable;
    
    MeanX = mean(xTable, 2);
    MeanZ = mean(zTable, 2);
    MeanX2 = mean(xTable.^2, 2);
    MeanXZ = mean(xTable.*zTable, 2);

    a_map = (MeanX2.*MeanZ-MeanX.*MeanXZ)./(MeanX2-MeanX.^2);
    b_map = (MeanXZ-MeanX.*MeanZ)./(MeanX2-MeanX.^2); 
        
    a_map_table = repmat(a_map, [1 length(x)]); 
    b_map_table = repmat(b_map, [1 length(x)]); 
    
    myFit = a_map_table + b_map_table.*xTable ;
    myError = sqrt(mean((myFit-imagesTable).^2./myFit.^2,2));

    if not(isempty(errorTh))
        errorMask = (myError > errorTh);
    else
        errorMask = zeros(mySize(1), 1); 
    end
    errorMask = errorMask + isnan(a_map)+isnan(b_map)+isinf(a_map)+isinf(b_map); 
    errorMask = logical(errorMask);
    
    if not(isempty(lowerBound))
        errorMask = errorMask + (b_map < lowerBound); 
        errorMask = logical(errorMask); 
    end
    if not(isempty(upperBound))
        errorMask = errorMask + (b_map > upperBound); 
        errorMask = logical(errorMask);  
    end
    
    a_map(errorMask) = NaN; 
    b_map(errorMask) = NaN; 
    
    mySize = size(argImagesTable);
    mySize = mySize(1:end-1); 
    
    if ndims(argImagesTable) > 2
        errorMask = reshape(errorMask, mySize);
        a_map = reshape(a_map, mySize);
        b_map = reshape(b_map, mySize);
    end
    
    varargout{1} = reshape(myFit, size(argImagesTable)); 
    varargout{2} = errorMask; 
    
end
