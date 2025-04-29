% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 



function [res,kspace_interp] = InterpolatekSpace(kspace, interp_kerns, kern_types, kernel)
[Nx,Ny,Nz,Nc] = size(kspace);
% kspace = kspace.*umask;
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
kspace_interp = zeros(size(kspace));

for x = 1+xstride:Nx-xstride
    for y = 1+ystride:Ny-ystride
        for iz = 1+zstride:Nz-zstride
        if kspace(x,y,iz)==0
%         interp_mat = interp_kerns{undersamp_shape(x,y)};
        kspace_kern = kspace(x-xstride:x+xstride, y-ystride:y+ystride, iz-zstride:iz+zstride);
        kspace_kern_mask = (abs(kspace_kern)>0);
        kspace_kern_mask = 1*kspace_kern_mask(:);
        kspace_kern_mask = normalize(kspace_kern_mask, "norm");
        type = find(abs((kern_types'*kspace_kern_mask) - 1)<1e-9);
        kern_mask = reshape(kspace_kern_mask, kernel);
        if isempty(type)
        else
        M = interp_kerns{type};
        calib_inp = [];
            for xx = -xstride:xstride
                for yy = -ystride:ystride
                    for zz = -zstride:zstride
                    if kern_mask(xx+xm,yy+ym, zz+zm)>0
                        calib_inp = [calib_inp;squeeze(kspace(x+xx,y+yy,iz+zz,:))];
                    end
                    end
                end
            end
         
         kspace_interp(x,y,iz,:)=M*calib_inp;
        end
        end
        
        end 
    end
%    100*x/Nx
end
res = kspace_interp+kspace;
end
% im5D(ifft2c_mri(kspace_interp+kspace))