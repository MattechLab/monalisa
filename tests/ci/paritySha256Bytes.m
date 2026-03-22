function hexStr = paritySha256Bytes(rawUint8)
%PARITYSHA256BYTES SHA-256 hex digest of a uint8 vector (column).
if isempty(rawUint8)
    rawUint8 = zeros(0, 1, 'uint8');
else
    rawUint8 = uint8(rawUint8(:));
end
import java.security.MessageDigest;
md = MessageDigest.getInstance('SHA-256');
md.update(rawUint8);
digest = typecast(md.digest, 'uint8');
h = dec2hex(double(digest), 2);
hexStr = lower(reshape(h', 1, []));
end
