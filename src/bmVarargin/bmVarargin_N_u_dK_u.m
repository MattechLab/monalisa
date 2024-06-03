% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [N_u, dK_u] = bmVarargin_N_u_dK_u(t, varargin)

[N_u, dK_u] = bmVarargin(varargin); 
[N_u, dK_u] = bmTraj_N_u_dK_u(t, N_u, dK_u); 

N_u     = double(single(N_u)); 
dK_u    = double(single(dK_u)); 

end