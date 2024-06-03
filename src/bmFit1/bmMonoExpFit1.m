% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [a_map varargout] = bmMonoExpFit1(argImagesTable, argX, argR, varargin)

    mySize = size(argImagesTable);
    mySize = [prod(mySize(1:end-1)) mySize(end)]; 
    
    if not(length(argX) == mySize(2))
        a_map = 0;  
        errordlg('Wrong list of arguments'); 
        return;  
    end

    errorTh = [];
    lowerBound = [];
    upperBound = []; 
    lsqLowerBound = [];
    lsqUpperBound = []; 
    lsqcurvefitFlag = 0; 
    
    if length(varargin) == 0
        1+1;
    elseif length(varargin) == 1
        errorTh = varargin{1}; 
    elseif length(varargin) == 3 
        errorTh = varargin{1}; 
        lowerBound = varargin{2}; 
        upperBound = varargin{3}; 
    elseif length(varargin) == 5 
        errorTh = varargin{1}; 
        lowerBound = varargin{2}; 
        upperBound = varargin{3}; 
        if strcmp(varargin{4},'Fit') && strcmp(varargin{5},'lsqcurvefit')
            lsqcurvefitFlag = 1; 
        end
    elseif length(varargin) == 7
        errorTh = varargin{1}; 
        lowerBound = varargin{2}; 
        upperBound = varargin{3}; 
        if strcmp(varargin{4},'Fit') && strcmp(varargin{5},'lsqcurvefit')
            lsqcurvefitFlag = 1;
            lsqLowerBound = varargin{6};
            lsqUpperBound = varargin{7};
        end
    else
        a_map = 0; 
        errordlg('Wrong list of arguments'); 
        return;
    end


    %definition of the fit-model for mono-exponential fitting
    mdl_mono_exp = @(beta,x)(beta*exp(-x*argR));


    %options for the fitting function
    opts = optimset('Display', 'off');
    
    imagesTable = reshape(argImagesTable, mySize); 
    iMax = mySize(2); 
    x = squeeze(argX)'; 

    a_map   = zeros(mySize(1), 1);
    
    xTable = reshape(x, [1 length(x)]); 
    xTable = repmat(xTable, [mySize(1) 1]); 
    zTable = log(imagesTable);
    
    MeanX = mean(xTable, 2);
    MeanZ = mean(zTable, 2);
    MeanX2 = mean(xTable.^2, 2);
    MeanXZ = mean(xTable.*zTable, 2);

    h = (MeanX2.*MeanZ-MeanX.*MeanXZ)./(MeanX2-MeanX.^2);
    aStartTable = exp(h);
    
    a_map = aStartTable; 
    
    if lsqcurvefitFlag
        for i = 1:mySize(1)
                if isnan(aStartTable(i))
                    a_map(i) = NaN;
                else
                    y = squeeze(imagesTable(i, :))';
                    
                    beta = aStartTable(i);
                    beta = lsqcurvefit(mdl_mono_exp , beta, x, y, lsqLowerBound, lsqUpperBound, opts);
                    a_map(i) = beta(1);
            end
        end
    end
    
    a_map_table = repmat(a_map, [1 length(x)]); 
    
    myFit = a_map_table.*exp(-argR*xTable);
    myError = sqrt(mean((myFit-imagesTable).^2./myFit.^2,2));

    if not(isempty(errorTh))
        errorMask = (myError > errorTh);
    else
        errorMask = zeros(mySize(1), 1); 
    end
    errorMask = errorMask + isnan(a_map); 
    errorMask = logical(errorMask);
    
    if not(isempty(lowerBound))
        errorMask = errorMask + (a_map < lowerBound); 
        errorMask = logical(errorMask); 
    end
    if not(isempty(upperBound))
        errorMask = errorMask + (a_map > upperBound); 
        errorMask = logical(errorMask);  
    end
    
    a_map(errorMask) = NaN; 
 
    mySize = size(argImagesTable);
    mySize = mySize(1:end-1); 
    
    if ndims(argImagesTable) > 2
        errorMask = reshape(errorMask, mySize);
        a_map = reshape(a_map, mySize);
    end
    
    varargout{1} = reshape(myFit, size(argImagesTable)); 
    varargout{2} = errorMask; 
    
end
