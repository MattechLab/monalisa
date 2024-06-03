% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

% v is the vector field. It must be reshapable is size [imDim, nPt_u] where
% imDim is the image dimension (1, 2, or 3) and nPt_u is the total number
% of pixel/voxel in the image. It holds nPt_u = prod(N_u(:)); 
%
% N_u is the image size, ex : N_u = [256, 192, 64]; 
%
% varargin :  [Dn, torus_flag]. 

function varargout = bmImDeformField2SparseMat(v, N_u, varargin)

% argin initial -----------------------------------------------------------

[Dn, torus_flag] = bmVarargin(varargin);

if iscell(v)
    
    if isempty(Dn)
        Dn = cell(size(v));
        for i = 1:size(v(:), 1)
            Dn{i} = [];
        end
    end
    
    if nargout == 1
        Gn  = cell(size(v));
        for i = 1:size(v(:), 1)
            Gn{i} = bmImDeformField2SparseMat(v{i}, N_u, Dn{i}, torus_flag);
        end
        varargout{1} = Gn; 
        return;
        
    elseif nargout == 2
        Gu  = cell(size(v));
        Gut = cell(size(v));
        for i = 1:size(v(:), 1)
            [Gu{i}, Gut{i}] = bmImDeformField2SparseMat(v{i}, N_u, Dn{i}, torus_flag);
        end
        varargout{1} = Gu;
        varargout{2} = Gut;
        return;
        
    elseif nargout == 3
        Gn  = cell(size(v));
        Gu  = cell(size(v));
        Gut = cell(size(v));
        for i = 1:size(v(:), 1)
            [Gn{i}, Gu{i}, Gut{i}] = bmImDeformField2SparseMat(v{i}, N_u, Dn{i}, torus_flag);
        end
        varargout{1} = Gn;
        varargout{2} = Gu;
        varargout{3} = Gut;
        return;
    else
        error('wrong list of arguments. ');
        return;
    end
end

if isempty(v)
   varargout{1} = []; 
   varargout{2} = []; 
   varargout{3} = [];
   return; 
end

if isempty(torus_flag)
    torus_flag = false; 
end

v           = double(bmPointReshape(v)); 
Dn          = double(Dn(:)');  
N_u         = double(N_u(:)'); 

nPt         = double(size(v, 2));
Nu_tot      = prod(N_u(:)); 


if nPt ~= prod(N_u(:))
   error(['In bmImDeformField2SparseMat : the deformation field must ', ...
          'have as many vectors as the number of pixel(voxel) in the image. ']);  
end
% END_argin initial -------------------------------------------------------

[ind_1, ind_2, myWeight, Dn] = bmImDeformField2sparseMat_ind_weight(v, N_u, Dn, torus_flag); 


if (nargout == 1) || (nargout == 3) % computing Gn
    mySparse  = sparse(ind_2, ind_1, myWeight.*Dn)';
    mySparse  = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);

    mySum = sum(mySparse, 2);
    [mySum_ind_1, ~, mySum] = find(mySum); 
    myDiag = sparse(mySum_ind_1, mySum_ind_1, 1./mySum); 
    myDiag = bmSparseMat_completeMatlabSparse(myDiag, [Nu_tot, Nu_tot]);
    
    mySparse = myDiag*mySparse; 
    mySparse = bmSparseMat_completeMatlabSparse(mySparse, [Nu_tot, nPt]);
    
    Gn = bmSparseMat_matlabSparse2bmSparseMat(mySparse, N_u, [1, 1, 1], 'bump', 2, []);
    Gn.cpp_prepare('one_block', [], []); 
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
    
    
    Gu  = bmSparseMat_matlabSparse2bmSparseMat(mySparse,  N_u, [1, 1, 1], 'bump', 2, []);
    Gut = bmSparseMat_matlabSparse2bmSparseMat(mySparse', N_u, [1, 1, 1], 'bump', 2, []);
    
    Gu.cpp_prepare('one_block', [], []); 
    Gut.cpp_prepare('one_block', [], []); 
    
end

mySparse = 0;
mySum = 0;
myDiag = 0;

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


