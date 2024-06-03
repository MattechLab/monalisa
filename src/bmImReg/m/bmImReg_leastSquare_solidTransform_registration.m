% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [v, T, x_reg] = bmImReg_leastSquare_solidTransform_registration(   x_ref_0, x_0, ...
                                                                            nIter_max_list, ...
                                                                            resolution_level_list, ...
                                                                            initialSolidTransform, ...
                                                                            X, Y, Z)

% method_param ------------------------------------------------------------
solidTransform_precision    = 1e-4; % -------------------------------------------------- magic_number
% END_method_param --------------------------------------------------------




% basic_param -------------------------------------------------------------                                        
n_u         = size(x_ref_0); 
imDim       = size(n_u(:), 1);  
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z); 
nLevel      = size(resolution_level_list(:), 1); 
if size(nIter_max_list(:), 1) == 1
   nIter_max_list = nIter_max_list*ones(1, nLevel);  
end
half_imRadius = mean(n_u(:)/2); 
% END_basic_param ---------------------------------------------------------




% initial_transform -------------------------------------------------------
if ~isempty(initialSolidTransform)
    T        = initialSolidTransform; 
else
    T        = bmImReg_solidTransform; 
    
    T.t      = zeros([imDim, 1], 'single'); 
    T.R      = eye(imDim); 
    T.c_ref  = bmImReg_getCenterMass_estimate(x_ref_0, X, Y, Z); 
end
% END_initial_transform ---------------------------------------------------




% registration ------------------------------------------------------------
test_im = []; 
for i = 1:nLevel
    
    disp(['Resolution_level number ', num2str(i)]);
    
    resolution_level = resolution_level_list(i);
    blackBorder      = 2*resolution_level*ones(1, imDim); 
    
    % filtereing ----------------------------------------------------------
    if resolution_level > 1
        x_ref       = bmImGaussFiltering(x_ref_0, resolution_level/2, blackBorder);
        x           = bmImGaussFiltering(x_0,     resolution_level/2, blackBorder);
    elseif resolution_level == 1
        x_ref       = x_ref_0;
        x           = x_0;
    end
    % END_filtereing ------------------------------------------------------
    
    
    
    
    
    % resacaling_and_imGradient -------------------------------------------
    n_x_ref     = mean(abs(x_ref(:)));
    n_x         = mean(abs(x(:)));
    n           = mean([n_x_ref, n_x]);
    x_ref       = x_ref/n;
    x           = x/n;
    x_imGrad    = bmImGradient(x);
    % END_resacaling_and_imGradient ---------------------------------------
    
    
    
    
    % registration_of_current_level ---------------------------------------
    nIter = 0;
    while true
        nIter = nIter + 1;
        
        T_prev = T;
        if imDim == 2
            [ng, p_0, objective_0] = private_get_negativeGradient2(T_prev, x_ref, x, x_imGrad, half_imRadius, X, Y, Z);
        elseif imDim == 3
            [ng, p_0, objective_0] = private_get_negativeGradient3(T_prev, x_ref, x, x_imGrad, half_imRadius, X, Y, Z);
        end
        l                          = private_get_lineSearch(x_ref, x, ng, p_0, objective_0, resolution_level, half_imRadius, X, Y, Z);
        p                          = p_0 + l*ng;
        T                          = private_get_transform(p, half_imRadius);
        
        
        
        
        % test --------------------------------------------------------------
        v                           = bmImReg_transform_to_deformField(T, n_u, X, Y, Z);
        x_reg                       = bmImReg_deform(v, x, n_u, X, Y, Z, 'cubic', false);
        test_im                     = cat(imDim+1, test_im, x_reg);
        % bmImage(x_ref - x_reg)
        % uiwait
        % END_test --------------------------------------------------------
        
        
        
        
        
        % break_condition -----------------------------------------------------
        d                   = bmImReg_solidTransform_distance(T, T_prev, half_imRadius)
        myBreakCondition    = (d < resolution_level*solidTransform_precision) || (  nIter >= nIter_max_list(i)  );
        if myBreakCondition
            disp(['Breaked at iteration ', num2str(nIter)]);
            break;
        end
        % END_break_condition ---------------------------------------------
        
        
        
    end
    % END_WHILE_registration_of_current_level -----------------------------
    
    
end
% END_FOR_registration ----------------------------------------------------


% final -------------------------------------------------------------------
v       = bmImReg_transform_to_deformField(T, n_u, X, Y, Z);
x_reg   = bmImReg_deform(v, x_0, n_u, X, Y, Z, 'cubic', false);
if ~isempty(test_im)
    bmImage(test_im)
end 
% END_final ---------------------------------------------------------------


end
% END_function ------------------------------------------------------------




function [ng, p_0, objective_0] = private_get_negativeGradient2(T_0, x_ref, x, imGradient, half_imRadius, X, Y, Z)
n_u         = size(x_ref); 
imDim       = size(n_u(:), 1);  
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z); 

p_0     = private_get_param(T_0, half_imRadius);
tx_0    = p_0(1, 1); 
ty_0    = p_0(1, 2); 
cx_0    = p_0(1, 3); 
cy_0    = p_0(1, 4);
alpha_0 = p_0(1, 5); 

v                       = bmImReg_transform_to_deformField(T_0, n_u, X, Y, Z);
x_deform                = bmImReg_deform(v, x, n_u, X, Y, Z, 'cubic', false);
gradX_x_deform          = bmImReg_deform(v, imGradient(:, :, 1), n_u, X, Y, Z, 'cubic', false);
gradY_x_deform          = bmImReg_deform(v, imGradient(:, :, 2), n_u, X, Y, Z,'cubic', false);

x_ref_minus_x_deform    = x_ref(:) - x_deform(:); 

myOmega   =     [
                    -sin(alpha_0/half_imRadius), -cos(alpha_0/half_imRadius);
                     cos(alpha_0/half_imRadius), -sin(alpha_0/half_imRadius)
                ];
            
dx_deform_dtX           = gradX_x_deform; 
dx_deform_dtY           = gradY_x_deform;

r_minus_c               = cat(1, X(:)' - cx_0, Y(:)' - cy_0); 
dv_dAlpha               = myOmega*r_minus_c; 
dvX_dAlpha              = dv_dAlpha(1, :)'; 
dvY_dAlpha              = dv_dAlpha(2, :)'; 

dx_deform_dAlpha        = gradX_x_deform(:).*dvX_dAlpha(:) + gradY_x_deform(:).*dvY_dAlpha(:); 

ng_tx               = sum(  x_ref_minus_x_deform(:).*dx_deform_dtX(:)  );
ng_ty               = sum(  x_ref_minus_x_deform(:).*dx_deform_dtY(:)  );
ng_alpha            = sum(  x_ref_minus_x_deform(:).*dx_deform_dAlpha(:)  ); % ^in radian^-1
ng                  = [ng_tx, ng_ty, 0, 0, ng_alpha/half_imRadius]; % in pixels^-1
objective_0         = 0.5*sum(  abs(x_ref_minus_x_deform(:)).^2  ); 
end

function [ng, p_0, objective_0] = private_get_negativeGradient3(T_0, x_ref, x, imGradient, half_imRadius, X, Y, Z)

n_u         = size(x_ref); 
imDim       = size(n_u(:), 1);  
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z); 

v                       = bmImReg_transform_to_deformField(T_0, n_u, X, Y, Z);
x_deform                = bmImReg_deform(v, x, n_u, X, Y, Z, 'cubic', false);
gradX_x_deform          = bmImReg_deform(v, imGradient(:, :, :, 1), n_u, X, Y, Z, 'cubic', false);
gradY_x_deform          = bmImReg_deform(v, imGradient(:, :, :, 2), n_u, X, Y, Z, 'cubic', false);
gradZ_x_deform          = bmImReg_deform(v, imGradient(:, :, :, 3), n_u, X, Y, Z, 'cubic', false);
x_ref_minus_x_deform    = x_ref(:) - x_deform(:); 

dx_deform_dtX           = gradX_x_deform; 
dx_deform_dtY           = gradY_x_deform;
dx_deform_dtZ           = gradZ_x_deform;

ng_tx                   = sum(  x_ref_minus_x_deform(:).*dx_deform_dtX(:)  );
ng_ty                   = sum(  x_ref_minus_x_deform(:).*dx_deform_dtY(:)  );
ng_tz                   = sum(  x_ref_minus_x_deform(:).*dx_deform_dtZ(:)  );








p_0     = private_get_param(T_0, half_imRadius);
tx_0    = p_0(1, 1); 
ty_0    = p_0(1, 2); 
tz_0    = p_0(1, 3); 
cx_0    = p_0(1, 4); 
cy_0    = p_0(1, 5);
cz_0    = p_0(1, 6);
psi_0   = p_0(1, 7); 
theta_0 = p_0(1, 8); 
phi_0   = p_0(1, 9); 
                
r_minus_c     = cat(1, X(:)' - cx_0, Y(:)' - cy_0, Z(:)' - cz_0);

[omega_psi, omega_theta, omega_phi] = bmOmega3(psi_0/half_imRadius, theta_0/half_imRadius, phi_0/half_imRadius); 

dv_dPsi                 = omega_psi*r_minus_c;
dv_dTheta               = omega_theta*r_minus_c;
dv_dPhi                 = omega_phi*r_minus_c;

dvX_dPsi                = dv_dPsi(1, :); 
dvY_dPsi                = dv_dPsi(2, :); 
dvZ_dPsi                = dv_dPsi(3, :);

dvX_dTheta              = dv_dTheta(1, :); 
dvY_dTheta              = dv_dTheta(2, :); 
dvZ_dTheta              = dv_dTheta(3, :);

dvX_dPhi                = dv_dPhi(1, :); 
dvY_dPhi                = dv_dPhi(2, :); 
dvZ_dPhi                = dv_dPhi(3, :);

dx_deform_dPsi          = gradX_x_deform(:).*dvX_dPsi(:)    + gradY_x_deform(:).*dvY_dPsi(:)    + gradZ_x_deform(:).*dvZ_dPsi(:);
dx_deform_dTheta        = gradX_x_deform(:).*dvX_dTheta(:)  + gradY_x_deform(:).*dvY_dTheta(:)  + gradZ_x_deform(:).*dvZ_dTheta(:);
dx_deform_dPhi          = gradX_x_deform(:).*dvX_dPhi(:)    + gradY_x_deform(:).*dvY_dPhi(:)    + gradZ_x_deform(:).*dvZ_dPhi(:);

ng_psi                  = sum(  x_ref_minus_x_deform(:).*dx_deform_dPsi(:)    ); % ^in radian^-1
ng_theta                = sum(  x_ref_minus_x_deform(:).*dx_deform_dTheta(:)  ); % ^in radian^-1
ng_phi                  = sum(  x_ref_minus_x_deform(:).*dx_deform_dPhi(:)    ); % ^in radian^-1





ng                      = [ng_tx, ng_ty, ng_tz, 0, 0, 0, ng_psi/half_imRadius, ng_theta/half_imRadius, ng_phi/half_imRadius]; % in pixels^-1
% ng                    = [ng_tx, ng_ty, ng_tz, 0, 0, 0, 0, 0, 0]; % in pixels^-1

objective_0             = 0.5*sum(  abs(x_ref_minus_x_deform(:)).^2  ); 
end


function l = private_get_lineSearch(x_ref, x, ng, p_0, objective_0, resolution_level, half_imRadius, X, Y, Z)

% method_param ------------------------------------------------------------                    
forw_tau    = 1.1; % ---------------------------------------------------------------- magic_number
back_tau    = 0.5; % ---------------------------------------------------------------- magic_number
delta_p_max = 0.5*resolution_level; % ----------------------------------------------- magic_number
c_armijo    = 0.2; % ---------------------------------------------------------------- magic_number
myEps       = 5e-6; % --------------------------------------------------------------- magic_number
% END_method_param 

n_u         = size(x_ref); 
imDim       = size(n_u(:), 1); 
[X, Y, Z]   = bmImGrid(n_u, X, Y, Z);  
m           = bmElipsoidMask(n_u, n_u/2); 
ng_sqn      = norm(ng)^2; 

% temp_l = []; 
% temp_r = []; 

l_max       = delta_p_max/norm(ng); 
l           = l_max; 


% back_tracking -----------------------------------------------------------

% first_iteration 
p               = p_0 + l*ng;   
T               = private_get_transform(p, half_imRadius); 
objective_prev  = private_get_objective(x_ref, x, T, X, Y, Z); 
% END_first_iteration 


% second_iteration 
l               = back_tau*l; 
p               = p_0 + l*ng;   
T               = private_get_transform(p, half_imRadius); 
objective_curr  = private_get_objective(x_ref, x, T, X, Y, Z); 
% END_second_iteration 


nIter = 0; 
while  true
    nIter = nIter + 1; 
    
    objective_prev  = objective_curr;
    
    l               = back_tau*l; 
    p               = p_0 + l*ng;   
    T               = private_get_transform(p, half_imRadius);
     
    objective_curr  = private_get_objective(x_ref, x, T, X, Y, Z); 
    
    
    cond_eps    = (l < myEps); 
    cond_armijo = (objective_curr < objective_0 - c_armijo*l*ng_sqn);
    cond_regrow = (objective_curr > objective_prev);
    cond_break  = (cond_armijo && cond_regrow) || cond_eps;
    if cond_break
        break;
    end
    
%     temp_l(nIter) = l; 
%     temp_r(nIter)  = objective_curr; 

end
% END_back_tracking -------------------------------------------------------

% figure
% hold on
% plot(temp_l, temp_r - objective_0, 'b.-')
% temp_l = [];
% temp_r = [];


% forw_tracking -----------------------------------------------------------

% first_iteration  
l_prev          = l;
objective_prev  = objective_curr; 
% END_first_iteration 


% second_iteration 
l               = forw_tau*l; 
p               = p_0 + l*ng; 
T               = private_get_transform(p, half_imRadius); 
objective_curr  = private_get_objective(x_ref, x, T, X, Y, Z); 
% END_second_iteration 

nIter = 0; 
while true
    nIter = nIter + 1; 
    
    l_prev          = l; 
    objective_prev  = objective_curr;
    
    l               = forw_tau*l; 
    p               = p_0 + l*ng;   
    T               = private_get_transform(p, half_imRadius);
     
    objective_curr  = private_get_objective(x_ref, x, T, X, Y, Z); 
    
    
    
    cond_armijo         = (objective_curr < objective_0 - c_armijo*l*ng_sqn);
    cond_descent        = (objective_curr < objective_prev);
    cond_l_max          = (l < l_max);
    cond_break          = ~(cond_armijo && cond_descent && cond_l_max);
    if cond_break
        break;
    end
    
    
%     temp_l(nIter) = l; 
%     temp_r(nIter)  = objective_curr; 

end
l = l_prev; 
% END_forw_tracking -------------------------------------------------------

% plot(temp_l, temp_r - objective_0, 'r.-')
% uiwait

end


function p = private_get_param(T, half_imRadius)

imDim = size(T.t(:), 1); 

if imDim == 2
    tx      = T.t(1, 1);
    ty      = T.t(2, 1);
    cx      = T.c_ref(1, 1);
    cy      = T.c_ref(2, 1);
    alpha = angle(  complex(T.R(1, 1), T.R(2, 1))  );
    
    p = [tx, ty, cx, cy, alpha*half_imRadius];

elseif imDim == 3
    tx      = T.t(1, 1);
    ty      = T.t(2, 1);
    tz      = T.t(3, 1);
    cx      = T.c_ref(1, 1);
    cy      = T.c_ref(2, 1);
    cz      = T.c_ref(3, 1);
    [psi, theta, phi] = bmPsi_theta_phi(T.R); 
    
    p = [tx, ty, tz, cx, cy, cz, psi*half_imRadius, theta*half_imRadius, phi*half_imRadius]; 

end

end



function T = private_get_transform(p, half_imRadius)

p = p(:)';

if size(p(:), 1) == 5
    
    tx      = p(1, 1);
    ty      = p(1, 2);
    cx      = p(1, 3);
    cy      = p(1, 4);
    alpha   = p(1, 5);
    
    T       = bmImReg_solidTransform;
    T.t     = cat(1, tx, ty);
    T.c_ref = cat(1, cx, cy);
    T.R     = bmRotation2(alpha/half_imRadius);
    
elseif size(p(:), 1) == 9
    
    tx      = p(1, 1);
    ty      = p(1, 2);
    tz      = p(1, 3);
    
    cx      = p(1, 4);
    cy      = p(1, 5);
    cz      = p(1, 6);
    
    psi     = p(1, 7);
    theta   = p(1, 8);
    phi     = p(1, 9);
    
    T       = bmImReg_solidTransform;
    T.t     = cat(1, tx, ty, tz);
    T.c_ref = cat(1, cx, cy, cz);
    T.R     = bmRotation3(psi/half_imRadius, theta/half_imRadius, phi/half_imRadius);

end
end



function myObjective = private_get_objective(x_ref, x, T, X, Y, Z) 

n_u             = size(x_ref); 

v               = bmImReg_transform_to_deformField(T, n_u, X, Y, Z);
x_deform        = bmImReg_deform(v, x, n_u, X, Y, Z, 'cubic', false);
myObjective     = 0.5*sum(  abs(x_ref(:) - x_deform(:)).^2  );

end

