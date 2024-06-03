% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023
%
% 'v'               is the deformField. 
% 'n_u'             is the image size. 
% 'every_n_line'    is the number of lines we skip + 1, for the plot. 
%                   (we don't want to plot every line, it is to much to 
%                   plot). 
%                   
%
% We work in image convention i.e. isotropic voxel_size with width equql 1
% in each dimension. 


function bmImDeformField_meshDisp2(v, n_u, every_n_line)

v = bmBlockReshape(v, n_u); 
v = bmImReg_deformField_to_positionField(v, n_u, [], [], [], false); 

vx = v(:, :, 1); 
vy = v(:, :, 2); 

figure; 
hold on

plot([1, 1], [1,  n_u(1, 1)], 'g-', 'Linewidth', 2)
plot([1, n_u(1, 2)], [1, 1], 'g-', 'Linewidth', 2)
plot([n_u(1, 2), n_u(1, 2)], [1,  n_u(1, 1)], 'g-', 'Linewidth', 2)
plot([1, n_u(1, 2)], [n_u(1, 1),  n_u(1, 1)], 'g-', 'Linewidth', 2)

for i = 1:every_n_line:n_u(1, 2)
    x = squeeze(vx(:, i));
    y = squeeze(vy(:, i));
    plot(y, x, 'b-'); 
end
x = squeeze(vx(:, end));
y = squeeze(vy(:, end));
plot(y, x, 'b-');

for i = 1:every_n_line:n_u(1, 1)
    x = squeeze(vx(i, :));
    y = squeeze(vy(i, :));
    plot(y, x, 'b-'); 
end
x = squeeze(vx(end, :));
y = squeeze(vy(end, :));
plot(y, x, 'b-');

x_min = min(vx(:)) - n_u(1, 1)/20; 
x_max = max(vx(:)) + n_u(1, 1)/20; 
y_min = min(vy(:)) - n_u(1, 2)/20; 
y_max = max(vy(:)) + n_u(1, 2)/20; 

plot(y_min, x_min, 'k.'); 
plot(y_min, x_max, 'k.');
plot(y_max, x_max, 'k.'); 
plot(y_max, x_min, 'k.'); 

set(gca, 'Box', 'on')
axis image

set(gca, 'YDir', 'reverse');

end




