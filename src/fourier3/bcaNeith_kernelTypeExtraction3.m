
% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 



function kern_types = KernelTypeExtraction(kspace,kernel)

[Nx,Ny,Nz,~] = size(kspace);

Nxk = kernel(1);
Nyk = kernel(2);
Nzk = kernel(3);

xstride = (Nxk-1)/2;
ystride = (Nyk-1)/2;
zstride = (Nzk-1)/2;

kern_types = [];
k = 1;
for i = Nx/2-xstride:Nx/2+xstride
    for j = 1+ystride:Ny-ystride
        for iz = 1+zstride:Nz-zstride
        if abs(kspace(i,j,iz)) == 0
        kspace_kern = kspace(i-xstride:i+xstride, j-ystride:j+ystride, iz-zstride:iz+zstride);
        kspace_kern_mask = (abs(kspace_kern)>0);
        kspace_kern_mask = 1*kspace_kern_mask(:);
        if norm(kspace_kern_mask(:))>0
            kspace_kern_mask = normalize(kspace_kern_mask, "norm");
        else
        end

        if k == 1
%             undersamp_shape(i,j) = k;
            kern_types(:,k) = kspace_kern_mask;
            k = k + 1;
        else
            if nnz(abs((kern_types'*kspace_kern_mask) - 1)<1e-9)
            else
                
%             undersamp_shape(i,j) = k;
            kern_types(:,k) = kspace_kern_mask;
            k = k + 1;
            end
        end
        end
        end
    end
end

end
