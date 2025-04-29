
% 
% Berk Can A�ikg�z
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 
% 


function sensemaps = bcaNeith_coilSensitivitySimulation2(Nx,Ny,Ncoils)

    sensemaps = zeros(Nx,Ny,Ncoils);
    ps = cell(5,1);
    p0 = @(x) ones(size(x)); ps{1} = p0;
    p1 = @(x) x; ps{2} = p1;
    p2 = @(x) (1/2)*(3*(x.^2) -1 ); ps{3} = p2;
    p3 = @(x) (1/2)*(5*(x.^3)-3*x); ps{4} = p3;
    p4 = @(x) (1/8)*(35*(x.^4)-30*(x.^2)+3); ps{5} = p4;
    p5 = @(x) (1/8)*(63*(x.^5)-70*(x.^3)+15*x); ps{6} = p5;


    [X,Y] = ndgrid(linspace(-1/2,1/2,Nx), linspace(-1/2, 1/2,Ny));
    b = zeros(9,Nx,Ny);
    k = 1;
    for i = 1:3
        for j = 1:3
%             subplot(4,4,((i-1)*4 + j))
            fx = ps{i}; fy = ps{j};
            b(k,:,:) = fx(X).*fy(Y);
%             imagesc(squeeze(b(k,:,:))), colorbar;
            k = k+1;
            
        end
    end

    for nc = 1:(Ncoils)
        map = squeeze(private_tensorprod(randn(1,size(b,1)), b, 2, 1)) + 1i*squeeze(private_tensorprod(randn(1,size(b,1)), b, 2, 1));
        sensemaps(:,:,nc) = private_rescale_mag(abs(map)).*exp(1i*angle(map));
    end

end



function tprod = private_tensorprod(A,B, dimA, dimB)

szA = size(A); 
szDimA = szA(dimA);
dimsA = 1:1:length(szA);
szA(dimA) = [];
dimsA(dimA) = [];

permuteA = permute(A, [dimsA, dimA]);
permuted_reshapedA = reshape(permuteA, prod(szA), szDimA);

szB = size(B); 
szDimB = szB(dimB);
dimsB = 1:1:length(szB);
szB(dimB) = [];
dimsB(dimB) = [];

permuteB = permute(B, [dimsB, dimB]);
permuted_reshapedB = reshape(permuteB, prod(szB), szDimB);

tprod = permuted_reshapedA*(permuted_reshapedB.');
tprod = reshape(tprod, [szA, szB]);

end




function res = private_rescale_mag(x)
    
    a = min(x(:));
    b = max(x(:));

    res = x*(1/(b-a));

end

