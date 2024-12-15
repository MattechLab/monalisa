function myCenter = bmTwix_getCenterOfLine(argFile)

myTwix = mapVBVD_JH_for_monalisa(argFile);
if iscell(myTwix)
    myTwix = myTwix{end};
end

y_raw = myTwix.image.unsorted();
y_raw = permute(y_raw, [2, 1, 3]);

nShot          = myTwix.image.NSeg;
nLine          = myTwix.image.NLin;
nSeg           = nLine/nShot;

mySize = size(y_raw);
mySize = mySize(:)';
y_raw  = reshape(y_raw, [mySize(1, 1), mySize(1, 2), nSeg, nShot]);

N = size(y_raw, 2);
myCenter = y_raw(:, N/2+1, :, :);
myCenter = reshape(myCenter, [mySize(1, 1), nLine]);

end