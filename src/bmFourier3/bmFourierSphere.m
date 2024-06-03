% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmFourierSphere(argK, argR, varargin)

if size(argK, 1)~= 3 && size(argK, 2) ~= 3
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
    myCenter = reshape(myCenter, [3 1]);
else
    myCenter = [0 0 0]';
end

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
k0_norm = sqrt(k0(1,:).^2+k0(2,:).^2+k0(3,:).^2) ;
k1_norm = 2*pi*k0_norm*argR;

myPhase = exp(-1i*2*pi*myCenter'*k0);


out = 4*pi*argR^3*ones(size(k0_norm));
out = out.*((sin(k1_norm)-k1_norm.*cos(k1_norm))./k1_norm.^3).*myPhase;
out(k0_norm < myMachineEpsilon) = 4/3*pi*argR^3;


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
