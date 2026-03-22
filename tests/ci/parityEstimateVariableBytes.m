function nBytes = parityEstimateVariableBytes(val)
%PARITYESTIMATEVARIABLEBYTES Rough byte count for parity size decisions.
if isempty(val)
    nBytes = 0;
    return;
end
if iscell(val)
    nBytes = 0;
    for i = 1:numel(val)
        nBytes = nBytes + parityEstimateVariableBytes(val{i});
    end
    return;
end
switch class(val)
    case {'double', 'int64', 'uint64'}
        nBytes = numel(val) * 8;
    case {'single', 'int32', 'uint32'}
        nBytes = numel(val) * 4;
    case 'logical'
        nBytes = numel(val);
    otherwise
        w = whos('val');
        nBytes = w.bytes;
end
if isnumeric(val) && ~isreal(val)
    nBytes = nBytes * 2;
end
end
