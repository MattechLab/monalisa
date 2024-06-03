% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImConv_fourier(a, b)

if (bmNdim(a) ==  1) && (bmNdim(b) ==  1)
    a = a(:);
    b = b(:);
end

Fa = bmImDFT(a);
Fb = bmImDFT(b);
out = Fa.*Fb;
out = bmImIDF(out);

end