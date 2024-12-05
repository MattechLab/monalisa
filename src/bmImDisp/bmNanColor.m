% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmNanColor(argImage)

if ndims(argImage) > 3
    error('Wrong list of arguments');
elseif ndims(argImage) == 3
    myImage = argImage(:,:,1); 
else
    myImage = argImage;  
end

    myZero = zeros(size(myImage)); 
    myNan = isnan(myImage); 
    myNanColor = cat(3, myZero, myZero, myNan/1.7);
    myImage(isnan(myImage)) = 0;
    myImage = myImage-min(myImage(:));
    myImage = myImage/max(myImage(:));
    myCImage = cat(3, myImage, myImage, myImage)+ myNanColor;
    
    figure
    image(myCImage); 
    axis image

end