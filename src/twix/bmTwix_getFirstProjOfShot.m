% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myLineList = bmTwix_getFirstProjOfShot(argFile, p)

myTwix = mapVBVD_JH_for_monalisa(argFile);
if iscell(myTwix)
    myTwix = myTwix{end};
end

y_raw = myTwix.image.unsorted();
y_raw = permute(y_raw, [2, 1, 3]); 

nLine          = myTwix.image.NLin;
if ~isempty(p)
    nShot          = p.nShot; 
else
    nShot          = myTwix.image.NSeg;
end
nSeg           = nLine/nShot;

mySize = size(y_raw); 
mySize = mySize(:)'; 
y_raw  = reshape(y_raw, [mySize(1, 1), mySize(1, 2), nSeg, nShot]); 

myLineList = squeeze(y_raw(:, :, 1, :));
myLineList = bmIDF(myLineList, 1, [], 2);

end