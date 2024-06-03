% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function varargout = bmDicomWrite(imagesTable, varargin)

    if ndims(imagesTable) > 3
       error('This function is for 2D images only');  
    end

    %imagesTable = uint32(imagesTable); 
    imagesTable = uint16(imagesTable); 
    
    myDir = 0; 
    myPath = 0; 
    myFileName = 0; 
    
    if nargin == 1
        [myDir myPath] = bmGetDir;  
        if isnumeric(myDir)
           return;  
        end
        
    elseif nargin == 2
        [myDir myPath] = bmGetDir;  
        if isnumeric(myDir)
           return;  
        end
        myFileName = varargin{1}; 
        
    elseif nargin > 2
        if mod(length(varargin),2) > 0
            error('Wrong list of arguments'); 
            return; 
        end
        
        for i = 1:2:length(varargin)
            switch varargin{i}
                case 'Dir'
                    myDir = varargin{i+1}; 
                case 'Name'
                    myFileName = varargin{i+1};
                case 'Path'
                    myPath = varargin{i+1};
                otherwise
                    error('Wrong list of arguments');
            end
        end
        
        
    end

    if isnumeric(myFileName)
       myFileName = '';  
    end
    
    if isnumeric(myDir) && isnumeric(myPath)
        error('Directory not specified')
        return; 
    end
    
    if isnumeric(myDir)
       myDir = myPath(1:end-1);  
    end
    myPath = [myDir '\'];  
    myFile = [myPath myFileName];
    
    if ndims(imagesTable) == 2
        dicomwrite(imagesTable, myFile);
    elseif ndims(imagesTable) == 3
        iMax = size(imagesTable,3);
        myNumList = bmNumList(iMax); 
        for i = 1:iMax
            dicomwrite(imagesTable(:,:,i),[myFile myNumList{i} '.dmc']);
        end
        
    end

    
end