function fp = parityFingerprintVariable(name, val)
%PARITYFINGERPRINTVARIABLE Stable fingerprint for parity comparison across forks.
%   Interop: column-major numeric bytes (MATLAB native) match NumPy order='F'
%   after reshape to the same dimensions.
fp = struct('name', name, 'class', class(val), 'size', size(val), ...
    'sha256', '', 'is_complex', logical(~isreal(val)));
if isempty(val)
    fp.sha256 = paritySha256Bytes(zeros(0, 1, 'uint8'));
    return;
end
if iscell(val)
    parts = cell(numel(val), 1);
    for i = 1:numel(val)
        sub = parityFingerprintVariable(sprintf('%s{%d}', name, i), val{i});
        parts{i} = char(sub.sha256);
    end
    joined = sprintf('%s|', parts{:});
    fp.sha256 = paritySha256Bytes(uint8(joined));
    return;
end
if ~(isnumeric(val) || islogical(val))
    error('parityFingerprintVariable:UnsupportedType', ...
        'Variable "%s" has unsupported class "%s".', name, class(val));
end
fp.sha256 = parityHashArrayInChunks(val);
end

function hexStr = parityHashArrayInChunks(val)
%PARITYHASHARRAYINCHUNKS Hash very large arrays without giant temporary buffers.
import java.security.MessageDigest;
md = MessageDigest.getInstance('SHA-256');

chunkElements = 5e6;

if islogical(val)
    v = val(:);
    n = numel(v);
    for s = 1:chunkElements:n
        e = min(s + chunkElements - 1, n);
        md.update(uint8(v(s:e)));
    end
elseif isnumeric(val) && isreal(val)
    v = val(:);
    n = numel(v);
    for s = 1:chunkElements:n
        e = min(s + chunkElements - 1, n);
        md.update(typecast(v(s:e), 'uint8'));
    end
else
    re = real(val(:));
    im = imag(val(:));
    n = numel(re);
    for s = 1:chunkElements:n
        e = min(s + chunkElements - 1, n);
        md.update(typecast(re(s:e), 'uint8'));
    end
    for s = 1:chunkElements:n
        e = min(s + chunkElements - 1, n);
        md.update(typecast(im(s:e), 'uint8'));
    end
end

digest = typecast(md.digest, 'uint8');
h = dec2hex(double(digest), 2);
hexStr = lower(reshape(h', 1, []));
end
