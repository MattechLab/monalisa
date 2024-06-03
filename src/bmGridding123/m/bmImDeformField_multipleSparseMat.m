% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% v is a cell-array of vector fields. Each must be reshapable is size 
% [imDim, nPt_u] where imDim is the image dimension (1, 2, or 3) and nPt_u 
% is the total number of pixel/voxel in the image. 
% It holds nPt_u = prod(N_u(:)); 
%
% N_u is the image size, ex : N_u = [256, 192, 64]; 
%
% varargin :  [Dn, torus_flag]. 

function varargout = bmImDeformField_multipleSparseMat(v, N_u, varargin)

% argin initial -----------------------------------------------------------

[Dn, torus_flag] = bmVarargin(varargin);

if isempty(torus_flag)
    torus_flag = false; 
end


Dn          = double(Dn(:)');  
N_u         = double(N_u(:)'); 
Nu_tot      = prod(N_u(:)); 
v           = v(:);
nCell       = size(v, 1);
nPt         = cell(nCell, 1);
for i = 1:nCell
    v{i}    = double(bmPointReshape(v{i}));
    nPt{i}  = double(size(v{i}, 2));
    
    if nPt{i} ~= prod(N_u(:))
        error(['In bmImDeformField_Gn_Gu_Gut : the deformation field must ', ...
            'have as many vectors as the number of pixel(voxel) in the image. ']);
    end
    
end

Gn  = bmMultipleSparseMat(nCell); 
Gu  = bmMultipleSparseMat(nCell); 
Gut = bmMultipleSparseMat(nCell); 

% END_argin initial -------------------------------------------------------


for i = 1:nCell
    
    [ind_1, ind_2, myWeight, Dn] = bmImDeformField_sparseMat_ind_weight(v{i}, N_u, Dn, torus_flag);
    
    if (nargout == 1) || (nargout == 3) % computing Gn
        mySparse  = sparse(ind_2, ind_1, myWeight.*Dn)';
        mySparse  = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);
        
        mySum = sum(mySparse, 2);
        [mySum_ind_1, ~, mySum] = find(mySum);
        myDiag = sparse(mySum_ind_1, mySum_ind_1, 1./mySum);
        myDiag = bmSparseMat_completeMatlabSparse(myDiag, [Nu_tot, Nu_tot]);
        
        mySparse = myDiag*mySparse;
        mySparse = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);
        
        bmSparseMat_matlabSparse2bmMultipleSparseMat(Gn, i, mySparse, N_u, [1, 1, 1], 'bump', 2, []);
        Gn.cpp_prepare('one_block', i);
    end
    
    mySparse = 0;
    mySum = 0;
    myDiag = 0;
    
    if (nargout == 2) || (nargout == 3) % computing Gu and Gut
        mySparse  = sparse(ind_2, ind_1, myWeight);
        mySparse  = bmSparseMat_completeMatlabSparse(mySparse, [nPt, Nu_tot]);
        
        mySum = sum(mySparse, 2);
        [mySum_ind_1, ~, mySum] = find(mySum);
        myDiag = sparse(mySum_ind_1, mySum_ind_1, 1./mySum);
        myDiag   = bmSparseMat_completeMatlabSparse(myDiag,   [nPt, nPt]);
        
        mySparse = myDiag*mySparse;
        mySparse = bmSparseMat_completeMatlabSparse(mySparse, [nPt, Nu_tot]);
        
        
        bmSparseMat_matlabSparse2bmMultipleSparseMat(Gu, i,  mySparse,  N_u, [1, 1, 1], 'bump', 2, []);
        bmSparseMat_matlabSparse2bmMultipleSparseMat(Gut, i, mySparse', N_u, [1, 1, 1], 'bump', 2, []);
        
        Gu.cpp_prepare('one_block', i);
        Gut.cpp_prepare('one_block', i);
        
    end
    
    mySparse = 0;
    mySum = 0;
    myDiag = 0;
    
end



if nargout == 1
    varargout{1} = Gn; 
elseif nargout == 2
    varargout{1} = Gu;
    varargout{2} = Gut;
elseif nargout == 3
    varargout{1} = Gn;
    varargout{2} = Gu;
    varargout{3} = Gut;
end

end % END_function


