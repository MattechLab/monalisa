% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [omega_psi, omega_theta, omega_phi] = bmOmega3(psi, theta, phi)

R_psi       = bmRotation3(psi,   0,   0); 
R_theta     = bmRotation3(0, theta,   0);
R_phi       = bmRotation3(0,     0, phi);


omega_psi       =   [
                        -sin(psi), -cos(psi), 0; 
                         cos(psi), -sin(psi), 0; 
                         0,         0       , 0; 
                    ];
                
omega_theta     =   [
                        -sin(theta), 0,  cos(theta); 
                                  0, 0,           0;
                        -cos(theta), 0, -sin(theta); 
                    ];
                
omega_phi       =   [
                        -sin(phi), -cos(phi), 0; 
                         cos(phi), -sin(phi), 0; 
                         0,         0       , 0; 
                    ];
                
omega_psi       = R_phi*R_theta*omega_psi; 
omega_theta     = R_phi*omega_theta*R_psi; 
omega_phi       = omega_phi*R_theta*R_psi; 

end