% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [b_map, a_map, varargout] = bmMonoExpFit(argImagesTable, argX, varargin)

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
    lsqLowerBound = [];
    lsqUpperBound = []; 
    lsqcurvefitFlag = 0; 
    
    if isempty(varargin)
        1+1;
    elseif isscalar(varargin)
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
        b_map = 0; 
        errordlg('Wrong list of arguments'); 
        return;
    end


    %definition of the fit-model for mono-exponential fitting
    mdl_mono_exp = @(beta,x)(beta(1)*exp(-x*beta(2)));


    %options for the fitting function
    opts = optimset('Display', 'off');
    
    imagesTable = reshape(argImagesTable, mySize); 
    iMax = mySize(2); 

    a_map   = zeros(mySize(1), 1);
    b_map   = zeros(mySize(1), 1);

    
    x = argX(:)'; 
    xTable = x; 
    xTable = repmat(xTable, [mySize(1) 1]); 
    zTable = log(imagesTable);
    
    MeanX = mean(xTable, 2);
    MeanZ = mean(zTable, 2);
    MeanX2 = mean(xTable.^2, 2);
    MeanXZ = mean(xTable.*zTable, 2);

    h = (MeanX2.*MeanZ-MeanX.*MeanXZ)./(MeanX2-MeanX.^2);
    aStartTable = exp(h);
    bStartTable = -(MeanXZ-MeanX.*MeanZ)./(MeanX2-MeanX.^2); 
    
    a_map = aStartTable; 
    b_map = bStartTable; 
    
    if lsqcurvefitFlag
        for i = 1:mySize(1)
                if isnan(aStartTable(i))||isnan(bStartTable(i))
                    a_map(i) = NaN;
                    b_map(i) = NaN;
                else
                    y = squeeze(imagesTable(i, :))';
                    x = x(:); 
                    
                    beta = [aStartTable(i) bStartTable(i)];
                    
                    beta = lsqcurvefit(mdl_mono_exp , beta, x, y, lsqLowerBound, lsqUpperBound, opts);
                    a_map(i) = beta(1);
                    b_map(i) = beta(2);
            end
        end
    end
    
    a_map_table = repmat(a_map, [1 length(x)]); 
    b_map_table = repmat(b_map, [1 length(x)]); 
    
    myFit = a_map_table.*exp(-b_map_table.*xTable);
    myError = sqrt(mean((myFit-imagesTable).^2./myFit.^2,2));

    if not(isempty(errorTh))
        errorMask = (myError > errorTh);
    else
        errorMask = zeros(mySize(1), 1); 
    end
    errorMask = errorMask + isnan(a_map)+isnan(b_map); 
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
