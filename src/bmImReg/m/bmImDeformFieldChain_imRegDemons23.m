% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% chain_type :      'curr_to_prev'      or
%                   'curr_to_next'      or
%                   'prev_to_curr'      or
%                   'next_to_curr'      or
%                   'curr_to_first'     or
%                   'first_to_curr'

function [imDeformField, varargout] = bmImDeformFieldChain_imRegDemons23(   x, ...
                                                                            n_u, ...
                                                                            chain_type, ...
                                                                            nIter, ...
                                                                            nSmooth, ...
                                                                            arg_name, ...
                                                                            varargin)

maxImVal = 255; % ----------------------------------------- magic number

[myMask, maxPixDisplacement] = bmVarargin(varargin); 

x = bmBlockReshape(x, n_u);

imDim           = size(n_u(:), 1); 
nCell           = size(x(:), 1);
imDeformField   = cell(nCell, 1);
im_out          = cell(nCell, 1);


if ~isempty(myMask)
    for i = 1:nCell
        x{i} = x{i}.*myMask;
    end
    myMask = repmat(myMask(:), [1, imDim]);
    myMask = bmBlockReshape(myMask, n_u);
end


for i = 1:nCell
    
    v_reg = [];
    
    i_minus_1 = mod(i-2, nCell) + 1;
    i_plus_1  = mod(i  , nCell) + 1;
    
    im_first    = single(private_smooth(x{1},         nSmooth));
    im_curr     = single(private_smooth(x{i},         nSmooth));
    im_prev     = single(private_smooth(x{i_minus_1}, nSmooth));
    im_next     = single(private_smooth(x{i_plus_1},  nSmooth));
    
    
    [im_first, min_first, max_first]    = private_rescale(im_first, maxImVal);
    [im_curr,  min_curr,  max_curr]     = private_rescale(im_curr,  maxImVal);
    [im_prev,  min_prev,  max_prev]     = private_rescale(im_prev,  maxImVal);
    [im_next,  min_next,  max_next]     = private_rescale(im_next,  maxImVal);
    
    
    if strcmp(chain_type,        'curr_to_prev')
        [v_reg, tmp_im]     = imregdemons(im_curr, im_prev, [nIter, fix(nIter/2), fix(nIter/4)]);
        tmp_im              = tmp_im*max_curr/maxImVal + min_curr;
    elseif strcmp(chain_type,    'curr_to_next')
        [v_reg, tmp_im]     = imregdemons(im_curr, im_next, [nIter, fix(nIter/2), fix(nIter/4)]);
        tmp_im              = tmp_im*max_curr/maxImVal + min_curr;
    elseif strcmp(chain_type,    'prev_to_curr')
        [v_reg, tmp_im]     = imregdemons(im_prev, im_curr, [nIter, fix(nIter/2), fix(nIter/4)]);
        tmp_im              = tmp_im*max_prev/maxImVal + min_prev;
    elseif strcmp(chain_type,    'next_to_curr')
        [v_reg, tmp_im]     = imregdemons(im_next, im_curr, [nIter, fix(nIter/2), fix(nIter/4)]);
        tmp_im              = tmp_im*max_next/maxImVal + min_next;
    elseif strcmp(chain_type,    'curr_to_first')
        if i == 1
            v_reg = [];
        elseif i > 1
            [v_reg, tmp_im] = imregdemons(im_curr, im_first, [nIter, fix(nIter/2), fix(nIter/4)]);
            tmp_im          = tmp_im*max_curr/maxImVal + min_curr;
        end
    elseif strcmp(chain_type,    'first_to_curr')
        if i == 1
            v_reg = [];
        elseif i > 1
            [v_reg, tmp_im] = imregdemons(im_first, im_curr, [nIter, fix(nIter/2), fix(nIter/4)]);
            tmp_im          = tmp_im*max_first/maxImVal + min_first;
        end
    else
        error('bmImDeformField_thirdPart : ''chain_type'' is unknown. ');
        return;
    end
    
    if ~isempty(v_reg)
        v_reg = private_flip_x_y(squeeze(v_reg));
    end
    
    im_out{i} = tmp_im; 
     
    v_reg               = bmBlockReshape(v_reg, n_u);
    if ~isempty(myMask)       
        v_reg           = v_reg.*myMask; 
    end
    if ~isempty(maxPixDisplacement)
        v_reg           = bmImDeformField_hardThresholding2(v_reg, n_u, maxPixDisplacement); 
    end
    v_reg               = bmPermuteToPoint(v_reg, n_u); 
    imDeformField{i}    = v_reg; 
    
end

varargout{1} = im_out;

save(arg_name,  'imDeformField',        '-v7.3');
save([arg_name, '_im_out'], 'im_out',   '-v7.3');

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
