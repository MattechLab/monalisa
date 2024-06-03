% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% sheet_type :      'curr_to_prev'      or
%                   'curr_to_next'      or
%                   'prev_to_curr'      or
%                   'next_to_curr'      or

function [imDeformField_1, imDeformField_2, varargout] = bmImDeformFieldSheet_imRegDemons23(    x, ...
                                                                                                n_u, ...
                                                                                                sheet_type, ...
                                                                                                nIter, ...
                                                                                                nSmooth, ...
                                                                                                arg_name)

maxImVal = 255; % -------------------------------------------------------------- magic number


imDim = size(n_u(:), 1); 
x = bmBlockReshape(x, n_u);

nIter = nIter(:)'; 
nIter_1 = nIter(1, 1);
nIter_2 = nIter(1, 2);

nCell_1             = size(x, 1);
nCell_2             = size(x, 2);
imDeformField_1     = cell(nCell_1, nCell_2);
imDeformField_2     = cell(nCell_1, nCell_2);
im_1                = cell(nCell_1, nCell_2);
im_2                = cell(nCell_1, nCell_2);

for i = 1:nCell_1
    for j = 1:nCell_2
        
        v_reg_1 = [];
        v_reg_2 = [];
        
        i_minus_1 = mod(i-2, nCell_1) + 1;
        i_plus_1  = mod(i  , nCell_1) + 1;
        j_minus_1 = mod(j-2, nCell_2) + 1;
        j_plus_1  = mod(j  , nCell_2) + 1;
        
        im_curr     = single(private_smooth(x{i, j},          nSmooth));
        im_prev_1   = single(private_smooth(x{i_minus_1, j},  nSmooth));
        im_next_1   = single(private_smooth(x{i_plus_1,  j},  nSmooth));
        im_prev_2   = single(private_smooth(x{i, j_minus_1},  nSmooth));
        im_next_2   = single(private_smooth(x{i,  j_plus_1},  nSmooth));
        
        
        [im_curr,    min_curr,    max_curr]     = private_rescale(im_curr,      maxImVal);
        [im_prev_1,  min_prev_1,  max_prev_1]   = private_rescale(im_prev_1,    maxImVal);
        [im_prev_2,  min_prev_2,  max_prev_2]   = private_rescale(im_prev_2,    maxImVal);
        [im_next_1,  min_next_1,  max_next_1]   = private_rescale(im_next_1,    maxImVal);
        [im_next_2,  min_next_2,  max_next_2]   = private_rescale(im_next_2,    maxImVal);
        
        
        if strcmp(sheet_type,        'curr_to_prev')
            [v_reg_1, tmp_im_1]  = imregdemons(im_curr, im_prev_1, nIter_1);
            tmp_im_1             = tmp_im_1*max_curr/maxImVal + min_curr;
            
            [v_reg_2, tmp_im_2]  = imregdemons(im_curr, im_prev_2, nIter_2);
            tmp_im_2             = tmp_im_2*max_curr/maxImVal + min_curr;
            
        elseif strcmp(sheet_type,    'curr_to_next')
            [v_reg_1, tmp_im_1]  = imregdemons(im_curr, im_next_1, nIter_1);
            tmp_im_1             = tmp_im_1*max_curr/maxImVal + min_curr;
            
            [v_reg_2, tmp_im_2]  = imregdemons(im_curr, im_next_2, nIter_2);
            tmp_im_2             = tmp_im_2*max_curr/maxImVal + min_curr;
            
        elseif strcmp(sheet_type,    'prev_to_curr')
            [v_reg_1, tmp_im_1]  = imregdemons(im_prev_1, im_curr, nIter_1);
            tmp_im_1             = tmp_im_1*max_prev_1/maxImVal + min_prev_1;
            
            [v_reg_2, tmp_im_2]  = imregdemons(im_prev_2, im_curr, nIter_2);
            tmp_im_2             = tmp_im_2*max_prev_2/maxImVal + min_prev_2;
            
        elseif strcmp(sheet_type,    'next_to_curr')
            [v_reg_1, tmp_im_1]  = imregdemons(im_next_1, im_curr, nIter_1);
            tmp_im_1             = tmp_im_1*max_next_1/maxImVal + min_next_1;
            
            [v_reg_2, tmp_im_2]  = imregdemons(im_next_2, im_curr, nIter_2);
            tmp_im_2             = tmp_im_2*max_next_2/maxImVal + min_next_2;
            
        else
            error(' ''sheet_type'' is unknown. ');
            return;
        end

        if (imDim == 3) && (~isempty(v_reg_1)) && (~isempty(v_reg_2))
            v_reg_1 = private_flip_x_y(squeeze(v_reg_1));
            v_reg_2 = private_flip_x_y(squeeze(v_reg_2));
        end
        
        imDeformField_1{i, j}    = bmPermuteToPoint(v_reg_1, n_u);
        imDeformField_2{i, j}    = bmPermuteToPoint(v_reg_2, n_u);
        
        im_1{i, j} = tmp_im_1; 
        im_2{i, j} = tmp_im_2; 
        
    end
end

varargout{1} = im_1;
varargout{2} = im_2;

save([arg_name, '_1'],      'imDeformField_1',  '-v7.3');
save([arg_name, '_2'],      'imDeformField_2',  '-v7.3');
save([arg_name, '_im_1'],   'im_1',             '-v7.3');
save([arg_name, '_im_2'],   'im_2',             '-v7.3');

end

function v_out = private_flip_x_y(v_in)

v_out        = squeeze(v_in);
temp_size    = bmCol(size(v_out))';
temp_imDim   = size(temp_size(:), 1) - 1;
temp_N_u     = temp_size(1, 1:temp_imDim);
v_out        = bmColReshape(v_out, temp_N_u);
temp_x       = v_out(:, 1);
v_out(:, 1)  = v_out(:, 2);
v_out(:, 2)  = temp_x;
v_out        = bmBlockReshape(v_out, temp_N_u);

end

function im_out = private_smooth(im_in, nSmooth)

N_u = size(im_in);
imDim = size(N_u(:), 1);
im_out = im_in;

if imDim == 1
    for i = 1:nSmooth
        im_out = (im_out + circshift(im_out, [1, 0])    + circshift(im_out, [-1, 0]))/3;
    end
elseif imDim == 2
    for i = 1:nSmooth
        im_out = (im_out + circshift(im_out, [1, 0])    + circshift(im_out, [0, 1])    + circshift(im_out, [-1, 0])   + circshift(im_out, [0, -1]))/5;
    end
elseif imDim == 3
    for i = 1:nSmooth
        im_out = (im_out + circshift(im_out, [1, 0, 0]) + circshift(im_out, [0, 1, 0]) + circshift(im_out, [0, 0, 1]) + circshift(im_out, [-1, 0, 0]) + circshift(im_out, [0, -1, 0]) + circshift(im_out, [0, 0, -1]) )/7;
    end
end

end

function [out, out_min, out_max] = private_rescale(arg_im, arg_val)
out     = abs(arg_im);
out_min = min(out(:));
out     = out - out_min;
out_max = max(out(:));
out     = out/out_max;
out     = out*arg_val;
end
