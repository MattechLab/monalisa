
% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 


function interp_kerns = InterpolatorExtraction(calib, kern_types, kernel)
[Nx,Ny,Nz,~] = size(calib);
% kernel = [7,7];
Nxk = kernel(1);
Nyk = kernel(2);
Nzk = kernel(3);
xstride = (Nxk-1)/2;
xm = (Nxk+1)/2;
ystride = (Nyk-1)/2;
ym = (Nyk+1)/2;
zstride = (Nzk-1)/2;
zm = (Nzk+1)/2;
kern_types = kern_types>0;
for i = 1:size(kern_types,2)
    t = 1;
    ci = [];
    co = [];
    kern_mask = reshape(kern_types(:,i), kernel);
    for x = 1+xstride:Nx-xstride
        for y = 1+ystride:Ny-ystride
            for iz = 1+zstride:Nz-zstride
            calib_inp = [];
            calib_out = [];
            for xx = -xstride:xstride
                for yy = -ystride:ystride
                    for zz = -zstride:zstride
                    if kern_mask(xx+xm,yy+ym,zz+zm)>0
                        calib_inp = [calib_inp;squeeze(calib(x+xx,y+yy,iz+zz,:))];
                    end
                    end
                end
            end
            if isempty(calib_inp)
            else
            ci(:,t) = calib_inp;
            calib_out = [calib_out, squeeze(calib(x,y,iz,:))];
            co(:,t) = calib_out;
            t = t+ 1;
            end
            end
        end
    end

%     M = co*pinv(ci);
    M = (pinv(ci.')*co.').';
    interp_kerns{i} = M;
%    i/size(kern_types,2)*100
end
end