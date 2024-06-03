% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [monoExpFit_2 biExpFit_1 biExpFit_2 biExpFit_3 varargout] = bmBiExpFit1(argImagesTable, argX, argX_middle, varargin)
% varargin  = [monoErrorTh biErrorTh monoLowerBound monoUpperBound biLowerBound biUpperBound]
% varargout = [monoExpFit biExpFit monoErrorMask biErrorMask]

% This code cointains some magic numbers ! Type "magic numbers" to find it. 

mySize = size(argImagesTable);
mySize = [prod(mySize(1:end-1)) mySize(end)]; 

if not(length(argX) == mySize(2))
    
    monoExpFit_2 = 0;
    biExpFit_1 = 0;
    biExpFit_2 = 0;
    biExpFit_3 = 0;
    
    errordlg('Wrong list of arguments');
    return;
end

    monoErrorTh = [];
    biErrorTh = [];
    monoLowerBound = [];
    monoUpperBound = [];
    biLowerBound = [];
    biUpperBound = [];
    

    if length(varargin) == 0
        1+1;
    elseif length(varargin) == 1
        monoErrorTh = varargin{1};
    elseif length(varargin) == 2
        monoErrorTh = varargin{1};
        biErrorTh = varargin{2};
    elseif length(varargin) == 4
        monoErrorTh = varargin{1};
        biErrorTh = varargin{2};
        monoLowerBound = varargin{3};
        monoUpperBound = varargin{4};
    elseif length(varargin) == 6
        monoErrorTh = varargin{1};
        biErrorTh = varargin{2};
        monoLowerBound = varargin{3};
        monoUpperBound = varargin{4};
        biLowerBound = varargin{5};
        biUpperBound = varargin{6};
    else
        
        monoExpFit_2 = 0;
        biExpFit_1 = 0;
        biExpFit_2 = 0;
        biExpFit_3 = 0;
        
        errordlg('Wrong list of arguments');
        return;
    end

%definition of the fit-model for mono-exponential fitting
mdl_mono_exp = @(beta,x)(beta(1)*exp(-x*beta(2)));

%definition of the fit-model for bi-exponential fitting
mdl_bi_exp = @(beta,x)(beta(4)*beta(1)*exp(-x*beta(2))+beta(4)*(1-beta(1))*exp(-x*beta(3)));

imagesTable = reshape(argImagesTable, mySize);
N = mySize(2);
x = squeeze(argX);
x = reshape(x, [length(x) 1]); 

monoExpFit_2    = zeros(mySize(1), 1);
biExpFit_1      = zeros(mySize(1), 1);
biExpFit_2      = zeros(mySize(1), 1);
biExpFit_3      = zeros(mySize(1), 1);
biExpFit_4      = zeros(mySize(1), 1);

% Fit mono exponentiel ----------------------------------------------------

xTable = reshape(x, [1 length(x)]);
xTable = repmat(xTable, [mySize(1) 1]);
zTable = log(imagesTable);

MeanX = mean(xTable, 2);
MeanZ = mean(zTable, 2);
MeanX2 = mean(xTable.^2, 2);
MeanXZ = mean(xTable.*zTable, 2);

h = (MeanX2.*MeanZ-MeanX.*MeanXZ)./(MeanX2-MeanX.^2);
monoExpFit_1_start = exp(h);
monoExpFit_2_start = -(MeanXZ-MeanX.*MeanZ)./(MeanX2-MeanX.^2);

monoExpFit_1 = monoExpFit_1_start; 
monoExpFit_2 = monoExpFit_2_start; 

%options for the fitting function

opts = optimset('Display', 'off');
%opts = optimset('Display', 'off', 'Algorithm', 'levenberg-marquardt');


lsqLowerBound = [];
lsqUpperBound = [];

for i = 1:mySize(1)
    if isnan(monoExpFit_1_start(i))||isnan(monoExpFit_2_start(i))
        monoExpFit_1(i) = NaN;
        monoExpFit_2(i) = NaN;
    else
        y = squeeze(imagesTable(i, :))';
        
        beta = [monoExpFit_1_start(i) monoExpFit_2_start(i)];
        beta = lsqcurvefit(mdl_mono_exp , beta, x, y, lsqLowerBound, lsqUpperBound, opts);
        monoExpFit_1(i) = beta(1);
        monoExpFit_2(i) = beta(2);
    end
end


monoExpFit_1_table = repmat(monoExpFit_1, [1 length(x)]);
monoExpFit_2_table = repmat(monoExpFit_2, [1 length(x)]);

myMonoExpFit = monoExpFit_1_table.*exp(-monoExpFit_2_table.*xTable);
myError = sqrt(mean((myMonoExpFit-imagesTable).^2./myMonoExpFit.^2,2));

 if not(isempty(monoErrorTh))
     monoErrorMask = (myError > monoErrorTh);
 else
     monoErrorMask = zeros(mySize(1), 1);
 end
 monoErrorMask = monoErrorMask + isnan(monoExpFit_1)+isnan(monoExpFit_2);
 monoErrorMask = logical(monoErrorMask);

%Fit biexponentiel --------------------------------------------------------

xEarlyMask   = (argX <= argX_middle); 
xEarlyMask_2 = (argX <= argX_middle/2); 
xLateMask  = (argX >= argX_middle); 

xEarly     = argX(xEarlyMask);
xEarly_2   = argX(xEarlyMask_2);
xLate      = argX(xLateMask);



xEarlyTable   = reshape(xEarly, [1 length(xEarly)]);
xEarlyTable   = repmat(xEarlyTable, [mySize(1) 1]);
zEarlyTable   = log(imagesTable(:,xEarlyMask));

xEarlyTable_2   = reshape(xEarly_2, [1 length(xEarly_2)]);
xEarlyTable_2   = repmat(xEarlyTable_2, [mySize(1) 1]);
zEarlyTable_2  = log(imagesTable(:,xEarlyMask_2));

MeanX_early = mean(xEarlyTable, 2);
MeanZ_early = mean(zEarlyTable, 2);
MeanX2_early = mean(xEarlyTable.^2, 2);
MeanXZ_early = mean(xEarlyTable.*zEarlyTable, 2);

MeanX_early_2 = mean(xEarlyTable_2, 2);
MeanZ_early_2 = mean(zEarlyTable_2, 2);
MeanX2_early_2 = mean(xEarlyTable_2.^2, 2);
MeanXZ_early_2 = mean(xEarlyTable_2.*zEarlyTable_2, 2);


h_early = (MeanX2_early.*MeanZ_early-MeanX_early.*MeanXZ_early)./(MeanX2_early-MeanX_early.^2);
biExpFit_2_start = -(MeanXZ_early-MeanX_early.*MeanZ_early)./(MeanX2_early-MeanX_early.^2);

h_early_2 = (MeanX2_early_2.*MeanZ_early_2-MeanX_early_2.*MeanXZ_early_2)./(MeanX2_early_2-MeanX_early_2.^2);
biExpFit_2_start_2 = -(MeanXZ_early_2-MeanX_early_2.*MeanZ_early_2)./(MeanX2_early_2-MeanX_early_2.^2);


xLateTable = reshape(xLate, [1 length(xLate)]);
xLateTable = repmat(xLateTable, [mySize(1) 1]);
zLateTable = log(imagesTable(:,xLateMask));

MeanX_late = mean(xLateTable, 2);
MeanZ_late = mean(zLateTable, 2);
MeanX2_late = mean(xLateTable.^2, 2);
MeanXZ_late = mean(xLateTable.*zLateTable, 2);

h_late = (MeanX2_late.*MeanZ_late-MeanX_late.*MeanXZ_late)./(MeanX2_late-MeanX_late.^2);
biExpFit_1_start = 1-exp(h_late);
biExpFit_3_start = -(MeanXZ_late-MeanX_late.*MeanZ_late)./(MeanX2_late-MeanX_late.^2);
biExpFit_4_start = ones(size(biExpFit_1_start)); 


for i = 1:mySize(1)
    if isnan(monoExpFit_2(i))||isnan(biExpFit_1_start(i))||isnan(biExpFit_2_start(i))||isnan(biExpFit_3_start(i))
        biExpFit_1(i) = NaN;
        biExpFit_2(i) = NaN;
        biExpFit_3(i) = NaN;
    else
        y = squeeze(imagesTable(i, :))';
        
        
%       lsqLowerBound = [0      20.0e-3           1e-4             0.7]; % magic numbers
%       lsqUpperBound = [1      80/1000           monoExpFit_2(i)  1.3]; % magic numbers

        lsqLowerBound = [0      monoExpFit_2(i)   1e-4             0.7]; % magic numbers
        lsqUpperBound = [1      80.0/1000         monoExpFit_2(i)  1.3]; % magic numbers


%         lsqLowerBound = []; % magic numbers
%         lsqUpperBound = []; % magic numbers


beta = [biExpFit_1_start(i) biExpFit_2_start(i) biExpFit_3_start(i) biExpFit_4_start(i)];
beta = real(lsqcurvefit(mdl_bi_exp , beta, x, y, lsqLowerBound, lsqUpperBound, opts));

biExpFit_1(i) = beta(1);
biExpFit_2(i) = beta(2);
biExpFit_3(i) = beta(3);
biExpFit_4(i) = beta(4);
    end
end

biExpFit_1_table = repmat(biExpFit_1, [1 length(x)]);
biExpFit_2_table = repmat(biExpFit_2, [1 length(x)]);
biExpFit_3_table = repmat(biExpFit_3, [1 length(x)]);
biExpFit_4_table = repmat(biExpFit_4, [1 length(x)]);

myBiExpFit  = biExpFit_4_table.*biExpFit_1_table.*exp(-biExpFit_2_table.*xTable) + biExpFit_4_table.*(1-biExpFit_1_table).*exp(-biExpFit_3_table.*xTable);
myError     = sqrt(mean((myBiExpFit-imagesTable).^2./myBiExpFit.^2,2));

 if not(isempty(biErrorTh))
     biErrorMask = (myError > biErrorTh);
 else
     biErrorMask = zeros(mySize(1), 1);
 end
 biErrorMask = biErrorMask + isnan(biExpFit_1)+isnan(biExpFit_2);
 biErrorMask = logical(biErrorMask);

 
 
 
 
 
% Reshaping and naNing 
myNewSize = size(argImagesTable);
myNewSize = myNewSize(1:end-1);

monoExpFit_1(monoErrorMask) = NaN;
monoExpFit_2(monoErrorMask) = NaN;

if ndims(argImagesTable) > 2
    monoErrorMask   = reshape(monoErrorMask, myNewSize);
    monoExpFit_1    = reshape(monoExpFit_1, myNewSize);
    monoExpFit_2    = reshape(monoExpFit_2, myNewSize);
end

 
 biExpFit_1(biErrorMask) = NaN;
 biExpFit_2(biErrorMask) = NaN;
 biExpFit_3(biErrorMask) = NaN;

if ndims(argImagesTable) > 2
    biErrorMask = reshape(biErrorMask, myNewSize);
    biExpFit_1  = reshape(biExpFit_1, myNewSize);
    biExpFit_2  = reshape(biExpFit_2, myNewSize);
    biExpFit_3  = reshape(biExpFit_3, myNewSize);
end

varargout{1} = reshape(myMonoExpFit, size(argImagesTable));
varargout{2} = reshape(myBiExpFit,   size(argImagesTable));
varargout{3} = monoErrorMask;
varargout{4} = biErrorMask;

end % end of the function
