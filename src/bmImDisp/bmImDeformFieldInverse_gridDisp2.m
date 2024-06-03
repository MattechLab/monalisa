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
% varargin{1} is an grey_scale image to display as background. 
%
% This function displays the inverse deformField by mean of a
% checherBoared. 


function bmImDeformFieldInverse_gridDisp2(v, n_u, cell_width, varargin)

nan_value = -1; % -------------------------------------------------------- magic_number

backGroundIm = bmVarargin(varargin); 

if cell_width < 2
    cell_width = 2; 
elseif cell_width > min(n_u)
    cell_width = min(n_u);
end

v = bmBlockReshape(v, n_u); 
v = bmImReg_deformField_to_positionField(v, n_u, [], [], [], true); 

vx = v(:, :, 1); 
vy = v(:, :, 2); 

X = 1:n_u(1, 1); 
Y = 1:n_u(1, 2);
[X, Y] = ndgrid(X, Y);

myIm_x  = private_checkerboard_x(n_u, cell_width); 
myIm_x  = interpn(X, Y, myIm_x, vx, vy, 'linear'); 
% myIm_x(isnan(myIm_x)) = nan_value; 
% gx1     = circshift(myIm_x, [-1, 0]) - myIm_x; 
% gx2     = circshift(myIm_x, [0, -1]) - myIm_x;


% image_gradient ----------------------------------------------------------
nExtend     = 0; 
myIm_x      = bmImExtend(myIm_x, nExtend); 
gx          = bmImGradient(myIm_x);
gx1         = gx(:, :, 1); 
gx2         = gx(:, :, 2); 
gx1         = bmImCrope(gx1, size(gx1), size(gx1) - 2*nExtend);
gx2         = bmImCrope(gx2, size(gx2), size(gx2) - 2*nExtend);
gx          = sqrt(gx1.^2 + gx2.^2);
% END_image_gradient ------------------------------------------------------
% gx        = double(gx >= 0.5); 




myIm_y  = private_checkerboard_y(n_u, cell_width); 
myIm_y  = interpn(X, Y, myIm_y, vx, vy, 'linear'); 
% myIm_y(isnan(myIm_y)) = nan_value; 
% gy1     = circshift(myIm_y, [-1, 0]) - myIm_y; 
% gy2     = circshift(myIm_y, [0, -1]) - myIm_y;

% image_gradient ----------------------------------------------------------
nExtend     = 0; 
myIm_y      = bmImExtend(myIm_y, nExtend); 
gy          = bmImGradient(myIm_y);
gy1         = gy(:, :, 1); 
gy2         = gy(:, :, 2); 
gy1         = bmImCrope(gy1, size(gy1), size(gy1) - 2*nExtend);
gy2         = bmImCrope(gy2, size(gy2), size(gy2) - 2*nExtend);
gy          = sqrt(gy1.^2 + gy2.^2);
% END_image_gradient ------------------------------------------------------
% gy        = double(gy >= 0.5); 



myIm                = sqrt(gx.^2 + gy.^2); 
% myIm(1:end, 1)      = 0;
% myIm(1:end, end)    = 0;
% myIm(1, 1:end)      = 0;
% myIm(end, 1:end)    = 0;


myIm(myIm < 0.3)    = 0;  
myIm                = min(0.5, myIm); 
m                   = (myIm > 0); 

myIm_r      = 0*myIm; 
myIm_g      = 2*myIm; 
myIm_b      = 0*myIm; 
myIm_rgb    = cat(3, myIm_r, myIm_g, myIm_b); 

if ~isempty(backGroundIm)
    
    backGroundIm = abs(backGroundIm); 
    backGroundIm = backGroundIm - min(backGroundIm(:)); 
    backGroundIm = backGroundIm/max(backGroundIm(:)); 
    
    b_r     = backGroundIm; b_r(m) = 0; 
    b_g     = backGroundIm; b_g(m) = 0; 
    b_b     = backGroundIm; b_b(m) = 0; 
    
    b_rgb   = cat(3, b_r, b_g, b_b); 
    
    myIm_rgb    = myIm_rgb + b_rgb; 
end

figure
image(myIm_rgb)
axis image

end




function myIm_x = private_checkerboard_x(n_u, cell_width)

myOne       = ones(cell_width, 1);
myZero      = zeros(cell_width, 1);
myOneZero   = cat(1, myOne, myZero); 

myColumn = []; 
for i = 1:ceil(  n_u(1, 1)/(2*cell_width)  )
   myColumn = cat(1, myColumn, myOneZero); 
end

myColumn    = myColumn(1:n_u(1, 1), 1); 
myIm_x      = repmat(myColumn, [1, n_u(1, 2)]); 

end



function myIm_y = private_checkerboard_y(n_u, cell_width)

myOne       = ones(1, cell_width);
myZero      = zeros(1, cell_width);
myOneZero   = cat(2, myOne, myZero); 

myRow = []; 
for i = 1:ceil(  n_u(1, 2)/(2*cell_width)  )
   myRow = cat(2, myRow, myOneZero); 
end

myRow       = myRow(1, 1:n_u(1, 2)); 
myIm_y      = repmat(myRow, [n_u(1, 1), 1]); 

end

