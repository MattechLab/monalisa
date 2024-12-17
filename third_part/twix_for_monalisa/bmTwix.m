function myTwix = bmTwix(argFile)


myTwix = mapVBVD_JH_for_monalisa(argFile);
if iscell(myTwix)
    myTwix = myTwix{end};
end


end