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
if islogical(val)
    raw = uint8(val(:));
elseif isreal(val)
    raw = typecast(val(:), 'uint8');
else
    re = real(val(:));
    im = imag(val(:));
    raw = [typecast(re, 'uint8'); typecast(im, 'uint8')];
end
fp.sha256 = paritySha256Bytes(raw);
end
