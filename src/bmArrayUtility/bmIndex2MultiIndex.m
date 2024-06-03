% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function outInd = bmIndex2MultiIndex(argInd, argSize)

myInd = argInd - 1; 
mySize = argSize(:)';
L = size(mySize, 2);

myOne = 1; myOne = myOne(:)'; 
mySize = cat(2, myOne, mySize); 

P = zeros(1, L);
for i = 1:L
    temp_size = mySize(1, 1:i);
    P(1, i) = prod(temp_size(:)); 
end


outInd = zeros(1, L); 
for i = 1:L
   temp_ind = fix(myInd/P(1, L + 1-i));
   outInd(1, L + 1-i) = temp_ind;
   myInd = myInd - temp_ind*P(1, L + 1-i); 
end

outInd = outInd + 1; 

end