function mySparse = bmSparseMat_completeMatlabSparse(argSparse, mySize)
% mySparse = bmSparseMat_completeMatlabSparse(argSparse, mySize)
%
% This function completes the sparse matrix to match the size given with
% the second argument. If the given size is bigger than the size of
% argSparse, argSparse is increased by adding all zero sparse matrices. If
% the given size is smaller or equal, no changes are done.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   argSparse (sparse matrix): The sparse matrix to be completed.
%   mySize (list): 1D array containing the size (column, row) that the
%   sparse matrix (argSparse) has to have at a minimum.
%
% Results:
%   mySparse (sparse matrix): argSparse padded with all zero sparse
%   matrices.

% Change input to be in the correct format
mySparse = argSparse;
a1 = double(size(mySparse, 1));
a2 = double(size(mySparse, 2));
mySize = mySize(:)';
b1 = double(mySize(1, 1));
b2 = double(mySize(1, 2));


if b1 > a1
    % Create all zero sparse matrix
    temp_sparse = sparse(b1 - a1, a2); 
    % Concatenate to have a1 == b1
    mySparse = cat(1, mySparse, temp_sparse); 
end

% Update a1
a1 = double(size(mySparse, 1)); 
a2 = double(size(mySparse, 2));

if b2 > a2
    % Create all zero sparse matrix
    temp_sparse = sparse(a1, b2 - a2);

    % Concatenate to have a2 == b2
    mySparse = cat(2, mySparse, temp_sparse);
end

end
