function outInd = bmIndex2MultiIndex(argInd, argSize)
    % bmIndex2MultiIndex Convert a linear index to a multi-dimensional index.
    %
    % This function takes a linear index (argInd) and the size of each dimension
    % (argSize) of a multi-dimensional array, and converts the linear index to
    % a multi-dimensional index.
    %
    % Parameters:
    %   argInd - The linear index to be converted.
    %   argSize - A vector specifying the size of each dimension of the
    %   multi-dimensional array.
    %
    % Returns:
    %   outInd - A vector containing the multi-dimensional index.
    %
    % Example:
    %   argInd = 5;
    %   argSize = [2, 3];
    %   outInd = bmIndex2MultiIndex(argInd, argSize)
    %   % outInd will be [2, 1] since the 5th element in a 2x3 matrix is at (2, 1).
    %
    % Author:
    %   Bastien Milani
    %   CHUV and UNIL
    %   Lausanne - Switzerland
    %   May 2023
    
    % Adjust for 0-based indexing
    myInd = argInd - 1; 
    mySize = argSize(:)';  % Ensure mySize is a row vector
    L = size(mySize, 2);   % Number of dimensions
    
    % Extend mySize with a leading 1 to simplify calculations
    myOne = 1; 
    myOne = myOne(:)'; 
    mySize = cat(2, myOne, mySize); 
    
    % Compute the cumulative product of dimensions
    P = zeros(1, L);
    for i = 1:L
        temp_size = mySize(1, 1:i);
        P(1, i) = prod(temp_size(:)); 
    end

    % Initialize output index
    outInd = zeros(1, L); 
    
    % Convert linear index to multi-dimensional index
    for i = 1:L
        temp_ind = fix(myInd / P(1, L + 1 - i));
        outInd(1, L + 1 - i) = temp_ind;
        myInd = myInd - temp_ind * P(1, L + 1 - i); 
    end
    
    % Adjust back to 1-based indexing
    outInd = outInd + 1; 
end
