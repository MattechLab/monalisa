% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function mySparse = bmSparseMat_completeMatlabSparse(argSparse, mySize)

mySparse = argSparse;
a1 = double(size(mySparse, 1));
a2 = double(size(mySparse, 2));
mySize = mySize(:)';
b1 = double(mySize(1, 1));
b2 = double(mySize(1, 2));


if b1 > a1
    temp_sparse = sparse(b1 - a1, a2);
    mySparse = cat(1, mySparse, temp_sparse);
end

a1 = double(size(mySparse, 1));
a2 = double(size(mySparse, 2));

if b2 > a2
    temp_sparse = sparse(a1, b2 - a2) ;
    mySparse = cat(2, mySparse, temp_sparse);
end

end
