% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myShiftList = bmImShiftList(argType, a, myPercent, varargin)

imDim = str2num(argType(end));

if imDim == 1
    out = -a:a;
    out = out(:);
    return;
end


disp_flag = bmVarargin(varargin);
if isempty(disp_flag)
    disp_flag = false;
end

myShiftList = [];

r_min = a;
r_max = sqrt(imDim)*a;
r = r_min + (r_max - r_min)*myPercent/100;


if imDim == 2
    l = -a:a;
    [x, y] = ndgrid(l, l);
    x = x(:);
    y = y(:);
    myGridd = [x, y];
elseif imDim == 3
    l = -a:a;
    [x, y, z] = ndgrid(l, l, l);
    x = x(:);
    y = y(:);
    z = z(:);
    myGridd = [x, y, z];
end


if strcmp(argType, 'sphere2')
    n = sqrt(x.^2 + y.^2);
elseif strcmp(argType, 'diamond2')
    n = abs(x) + abs(y);
elseif strcmp(argType, 'square2')
    n = max([abs(x), abs(y)], [], 2);
elseif strcmp(argType, 'sphere3')
    n = sqrt(x.^2 + y.^2 + z.^2);
elseif strcmp(argType, 'diamond3')
    n = abs(x) + abs(y) + abs(z);
elseif strcmp(argType, 'square3')
    n = max([abs(x), abs(y), abs(z)], [], 2);
else
    error('Type of imShiftList is unknown. ');
    return; 
end

n_mask = (n <= r);
myShiftList = myGridd(n_mask, :);


if disp_flag
    myImage = bmImShiftList_to_image(myShiftList); 
    bmImage(myImage);
end

end