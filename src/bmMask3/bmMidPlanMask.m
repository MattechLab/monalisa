% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function c = bmMidPlanMask(a, b, d_plan, d_mid)

if (sum(abs(a(:))) == 0) || (sum(abs(b(:))) == 0)
   c = zeros(size(a, 1), size(a, 2), length(d_mid(:))); 
   return; 
end

d_mid = d_mid(:); 

[x_a, y_a] = ndgrid(1:size(a, 1), 1:size(a, 2)); 
x_a = mean(x_a(logical(a(:))));
y_a = mean(y_a(logical(a(:))));

[x_b, y_b] = ndgrid(1:size(b, 1), 1:size(b, 2)); 
x_b = mean(x_b(logical(b(:))));
y_b = mean(y_b(logical(b(:))));



bound_a = bwboundaries(a); bound_a = bound_a{1};
bound_b = bwboundaries(b); bound_b = bound_b{1};

bound_a = cat(1, bound_a(:, 1)', bound_a(:, 2)');
bound_b = cat(1, bound_b(:, 1)', bound_b(:, 2)');


phase_a = angle(complex(bound_a(1, :) - x_a, bound_a(2, :) - y_a));
phase_b = angle(complex(bound_b(1, :) - x_b, bound_b(2, :) - y_b));

[~, minInd_a] = min(phase_a);
[~, minInd_b] = min(phase_b);

bound_a = [bound_a(:, minInd_a:end), bound_a(:, 1:minInd_a - 1)];
bound_b = [bound_b(:, minInd_b:end), bound_b(:, 1:minInd_b - 1)];


c = zeros(size(a, 1), size(a, 2), size(d_mid(:), 1)); 
L_a = size(bound_a, 2);
L_b = size(bound_b, 2);



for k = 1:size(d_mid(:), 1)
        
    r = zeros(2, L_a);
    for i = 1:L_a
        
        j = round(L_b*i/L_a);
        j = max(j, 1);
        j = min(j, L_b);
        
        p = bound_a(:, i); 
        q = bound_b(:, j); 
        
        r_temp = round(p + (q - p)*d_mid(k, 1)/d_plan);
        r(:, i) = r_temp(1:2, 1); 
        
    end
    
    c(:, :, k) = roipoly(a, r(2, :), r(1, :));
    
end



end