% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function m = bmCoilSense_nonCart_mask(y, Gn, varargin)

colorMax = 100; % ------------------------------------------------------------------- magic number

[   x_min, x_max, ...
    y_min, y_max, ...
    z_min, z_max, ...
    th_RMS, th_MIP, ...
    open_size, ...
    close_size, ...
    display_flag]    = bmVarargin(varargin);

N_u     = double(Gn.N_u(:)');
imDim   = size(N_u(:), 1);
x       = bmBlockReshape(bmNasha(y, Gn, N_u), N_u);

myRMS = bmRMS(x, N_u);
myMIP = bmMIP(x, N_u);


myRMS = colorMax*(myRMS - min(myRMS(:)))/max(myRMS(:));
myMIP = colorMax*(myMIP - min(myMIP(:)))/max(myMIP(:));

nPix = size(myRMS(:), 1);

n_RMS = zeros(1, colorMax);
n_MIP = zeros(1, colorMax);

for i = 0:colorMax-1
    n_RMS(1, i+1) = sum(myRMS(:) > i)/nPix;
    n_MIP(1, i+1) = sum(myMIP(:) > i)/nPix;
end

if display_flag
    figure
    hold on
    plot(n_RMS, '.-');
    plot(n_MIP, '.-');
    bmImage(myRMS)
    title('RMS')
    bmImage(myMIP)
    title('MIP')
end

m = true(size(myRMS));

if not(isempty(th_RMS)) & isempty(th_MIP)
    m = (myRMS > th_RMS) & (myMIP > th_RMS);
elseif isempty(th_RMS) & not(isempty(th_MIP))
    m = (myRMS > th_MIP) & (myMIP > th_MIP);
elseif not(isempty(th_RMS)) & not(isempty(th_MIP))
    m = (myRMS > th_RMS) & (myMIP > th_MIP);
end



if imDim == 1
    if not(isempty(x_min)) && not(isempty(x_max))
        m(1:x_min, 1)   = false;
        m(x_max:end, 1) = false;
    end
end
if imDim == 2
    if not(isempty(x_min)) && not(isempty(x_max))
        m(1:x_min, :)   = false;
        m(x_max:end, :) = false;
    end
    if not(isempty(y_min)) && not(isempty(y_max))
        m(:, 1:y_min)   = false;
        m(:, y_max:end) = false;
    end
end
if imDim == 3
    if not(isempty(x_min)) && not(isempty(x_max))
        if x_min > 1
            m(1:x_min-1,   :, :)  = false;
        end
        if x_max < N_u(1, 1)
            m(x_max+1:end, :, :)  = false;
        end
    end
    if not(isempty(y_min)) && not(isempty(y_max))
        if y_min > 1
            m(:, 1:y_min-1,   :)  = false;
        end
        if y_max < N_u(1, 2)
            m(:, y_max:end, :)  = false;
        end
    end
    if not(isempty(z_min)) && not(isempty(z_max))
        if z_min > 1
            m(:, :, 1:z_min)    = false;
        end
        if z_max < N_u(1, 3)
            m(:, :, z_max:end)  = false;
        end
    end
end




if not(isempty(open_size))
    if open_size > 0
        m = bmImOpen(m, bmImShiftList(['sphere', num2str(imDim)], open_size, 0));
    end
end
if not(isempty(close_size))
    if close_size > 0
        m = bmImClose(m, bmImShiftList(['sphere', num2str(imDim)], close_size, 0));
    end
end



if sum(m(:) == false) > 0
    temp_im = m.*myRMS;
    temp_im = cat(2, temp_im/max(abs(temp_im(:))), m);
    if display_flag
        bmImage(temp_im)
    end
end

m = bmBlockReshape(m, N_u);

end

