% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmFourierSquare(argK, argEdge, varargin)

a = 0;
b = 0;

if length(argEdge(:)) == 1
    a = argEdge(1);
    b = argEdge(1);
elseif length(argEdge(:)) == 2
    a = argEdge(1);
    b = argEdge(2);
else
    error('Wrong list of arguments. ')
    return;
end

if (a <= 0) || (b <= 0)
    error('Wrong list of arguments. ')
    return;
end

if size(argK, 1)~= 2 && size(argK, 2) ~= 2
    error('Wrong list of arguments');
    return;
end


if length(varargin) > 0
    myCenter = varargin{1};
    myCenter = myCenter(:); 
else
    myCenter = [0 0]';
end

% method_parameter --------------------------------------------------------
myMachineEpsilon = 2*eps; % -------------------------------------------------- magic number
% end_method_parameter ----------------------------------------------------


myPerm = 1:ndims(argK);
if size(argK, 1) == 2
    k = argK;
elseif size(argK, 2) == 2
    myPerm(1) = 2;
    myPerm(2) = 1;
    k = permute(argK, myPerm);
end
k_size = size(k);
mySize = [2 prod(k_size(2:end))];

k0 = reshape(k, mySize);

myX = sin(pi*k0(1, :)*a)./(pi*k0(1, :));
myY = sin(pi*k0(2, :)*b)./(pi*k0(2, :));

myX( abs(k0(1, :)) < myMachineEpsilon  ) = a; 
myY( abs(k0(2, :)) < myMachineEpsilon  ) = b;  


if ~isequal(myCenter, [0, 0]')
    myI = complex(0, 1);
    myX = myX.*exp(myI*2*pi*myCenter(1)*k0(1, :));
    myY = myY.*exp(myI*2*pi*myCenter(2)*k0(2, :));
end

out = myX.*myY;



if (ndims(argK)==2) & (size(argK,1) == 2)
    out = reshape(out, [1 length(out)]);
elseif (ndims(argK) == 2) & (size(argK,2) == 2)
    out = reshape(out, [length(out) 1]);
elseif (ndims(argK) > 2) & (size(argK,1) == 2)
    out = reshape(out, [1 k_size(2:end)]);
elseif (ndims(argK) > 2) & (size(argK,2) == 2)
    out = reshape(out, [k_size(2) 1 k_size(3:end)]);
end


end
