% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023
%
% 'v'               is the deformField. 
% 'n_u'             is the image size. 
% 'cell_width'      is the width of a cell of the checkerBoared. It must be
%                   equal or larger to 2. 
%                   
%
% We work in image convention i.e. isotropic voxel_size with width equql 1
% in each dimension. 
%
% This function displays the inverse deformField by mean of a
% checherBoared. 


function bmImDeformFieldInverse_checkerboardDisp2(v, n_u, cell_width)

if cell_width < 2
    cell_width = 2; 
elseif cell_width > min(n_u)
    cell_width = min(n_u);
end

v = bmBlockReshape(v, n_u); 
v = bmImReg_deformField_to_positionField(v, n_u, [], [], [], false); 

vx = v(:, :, 1); 
vy = v(:, :, 2); 

myIm = private_checkerboard(n_u, cell_width); 

X = 1:n_u(1, 1); 
Y = 1:n_u(1, 2);
[X, Y] = ndgrid(X, Y);

myIm = interpn(X, Y, myIm, vx, vy, 'linear'); 
myIm(isnan(myIm)) = 0; 
bmImage(myIm); 

end




function myIm = private_checkerboard(n_u, cell_width)

myOne       = ones(cell_width, 1);
myZero      = zeros(cell_width, 1);
myOneZero   = cat(1, myOne, myZero); 

myColumn = []; 
for i = 1:ceil(  n_u(1, 1)/(2*cell_width)  )
   myColumn = cat(1, myColumn, myOneZero); 
end
myColumn = myColumn(1:n_u(1, 1), 1); 

myColumn_1 = myColumn; 
myColumn_2 = double(not(logical(myColumn_1))); 


myBlock_1 = []; 
myBlock_2 = []; 
for i = 1:cell_width
    myBlock_1 = cat(2, myBlock_1, myColumn_1); 
    myBlock_2 = cat(2, myBlock_2, myColumn_2); 
end

myBlock = cat(2, myBlock_1, myBlock_2); 

myIm = []; 
for i = 1:ceil(  n_u(1, 2)/(2*cell_width)  )
   myIm = cat(2, myIm, myBlock); 
end
myIm = myIm(:, 1:n_u(1, 2)); 

end