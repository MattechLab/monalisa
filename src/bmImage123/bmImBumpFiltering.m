% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmImBumpFiltering(argIm, nPixFilter)

myPlus = 10;  % -------------------------------------------------------------- magic number
mySmall = 0.1; % ------------------------------------------------------------- magic number


myMean_0 = mean(argIm(:));
plus_flag = false; 
if abs(myMean_0) < mySmall 
    argIm = argIm + myPlus;
    myMean_0 = mean(argIm(:)); 
    plus_flag = true; 
end

argSize = size(argIm); 
[argIm, imDim, imSize, Nx, Ny, Nz] = bmImReshape(argIm); 


Nx_mid = []; 
Ny_mid = []; 
Nz_mid = []; 
if imDim == 1
    Nx_mid = fix(Nx/2 + 1); 
    
    [x] = ndgrid(1:Nx);
    
    x = x - Nx_mid;
    n = sqrt(x.^2);
    
    K = bmBump(n, nPixFilter);  
end

if imDim == 2
    
    Nx_mid = fix(Nx/2 + 1); 
    Ny_mid = fix(Ny/2 + 1); 
    
    [x, y] = ndgrid(1:Nx, 1:Ny);

    x = x - Nx_mid;
    y = y - Ny_mid; 
    n = sqrt(x.^2 + y.^2); 
    
    K = bmBump(n, nPixFilter); 
    
end

if imDim == 3
    
    Nx_mid = fix(Nx/2 + 1); 
    Ny_mid = fix(Ny/2 + 1); 
    Nz_mid = fix(Nz/2 + 1); 

    [x, y, z] = ndgrid(1:Nx, 1:Ny, 1:Nz);

    x = x - Nx_mid;
    y = y - Ny_mid; 
    z = z - Nz_mid; 
    n = sqrt(x.^2 + y.^2 + z.^2); 
    
    K = bmBump(n, nPixFilter); 
    
end



FK = bmImDFT(K); 

out = bmImDFT(argIm);
out = out.*FK; 
out = real(bmImIDF(out)); 

out = reshape(out, argSize); 
out = out/mean(out(:))*myMean_0; 

if plus_flag
   out = out - myPlus;  
end


end