% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% argK can be of any shape of the form (2 or 3, n2, n1, ..., nM)

function out = bmFourierDisc(argK, argR, varargin)

if size(argK, 1)~= 2 && size(argK, 2) ~= 2
    error('Wrong list of arguments');
    return;
end

if argR <= 0
    error('Wrong list of arguments. ')
    return;
end

% method_parameter --------------------------------------------------------
myMachineEpsilon = 1e-15; 
% end_method_parameter ----------------------------------------------------

if length(varargin) > 0
    myCenter = varargin{1};
    myCenter = reshape(myCenter, [2 1]);
else
    myCenter = [0 0]';
end

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
k0_norm = sqrt(k0(1,:).^2+k0(2,:).^2);
k1_norm = 2*pi*k0_norm*argR;

myPhase = exp(1i*2*pi*myCenter'*k0);

out = 2*pi*argR^2*ones(size(k0_norm));
out = out.*(besselj(1, k1_norm)./k1_norm).*myPhase;
out(k0_norm < myMachineEpsilon) = pi*argR^2;


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
