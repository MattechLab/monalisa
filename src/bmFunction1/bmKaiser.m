% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function y = bmKaiser(x, alpha, tau)

I0alpha = besseli(0, alpha);

y  = max(1-(x/tau).^2, 0);
y = alpha*sqrt(y);
y = besseli(0, y)/I0alpha;

end