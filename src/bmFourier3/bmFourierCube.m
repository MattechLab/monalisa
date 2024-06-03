% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmFourierCube(argK, argEdge, varargin)

a = 0;
b = 0;
c = 0;

if length(argEdge(:)) == 1
    a = argEdge(1);
    b = argEdge(1);
    c = argEdge(1);
elseif length(argEdge(:)) == 3
    a = argEdge(1);
    b = argEdge(2);
    c = argEdge(3);
else
    error('Wrong list of arguments. ')
    return;
end

if (a <= 0) || (b <= 0) || (c <= 0)
    error('Wrong list of arguments. ')
    return;
end

if size(argK, 1)~= 3 && size(argK, 2) ~= 3
    error('Wrong list of arguments');
    return;
end


if length(varargin) > 0
    myCenter = varargin{1};
    myCenter = reshape(myCenter, [3 1]);
else
    myCenter = [0 0 0]';
end

% method_parameter --------------------------------------------------------
myMachineEpsilon = 2*eps;
% end_method_parameter ----------------------------------------------------


myPerm = 1:ndims(argK);
if size(argK, 1) == 3
    k = argK;
elseif size(argK, 2) == 3
    myPerm(1) = 2;
    myPerm(2) = 1;
    k = permute(argK, myPerm);
end
k_size = size(k);
mySize = [3 prod(k_size(2:end))];

k0 = reshape(k, mySize);

myX = sin(pi*k0(1, :)*a)./(pi*k0(1, :));
myY = sin(pi*k0(2, :)*b)./(pi*k0(2, :));
myZ = sin(pi*k0(3, :)*c)./(pi*k0(3, :));

myX( abs(k0(1, :)) < myMachineEpsilon  ) = a; 
myY( abs(k0(2, :)) < myMachineEpsilon  ) = b; 
myZ( abs(k0(3, :)) < myMachineEpsilon  ) = c; 


if ~isequal(myCenter, [0, 0, 0]')
    myI = complex(0, 1);
    myX = myX.*exp(-myI*2*pi*myCenter(1)*k0(1, :));
    myY = myY.*exp(-myI*2*pi*myCenter(2)*k0(2, :));
    myZ = myZ.*exp(-myI*2*pi*myCenter(3)*k0(3, :));
end

out = myX.*myY.*myZ;



if (ndims(argK)==2) & (size(argK,1) == 3)
    out = reshape(out, [1 length(out)]);
elseif (ndims(argK) == 2) & (size(argK,2) == 3)
    out = reshape(out, [length(out) 1]);
elseif (ndims(argK) > 2) & (size(argK,1) == 3)
    out = reshape(out, [1 k_size(2:end)]);
elseif (ndims(argK) > 2) & (size(argK,2) == 3)
    out = reshape(out, [k_size(2) 1 k_size(3:end)]);
end
end
