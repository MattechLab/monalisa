% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myMask = bmSmoothMask3(argMask, nPixFilter)

myMask = argMask; 


for i = 1:size(myMask, 3)
    temp_mask = myMask(:, :, i);
    temp_bound = bwboundaries(temp_mask);
    if size(temp_bound) > 0
        
        sum_mask = false(size(temp_mask)); 
        for j = 1:length(temp_bound)
            temp_bound_j = temp_bound{j};
            x = temp_bound_j(: ,2);
            y = temp_bound_j(:, 1);
            x = bmImBumpFiltering1(x, nPixFilter);
            y = bmImBumpFiltering1(y, nPixFilter);
            
            sum_mask = sum_mask | roipoly(temp_mask, x, y); 
        end 
        myMask(:, :, i) = sum_mask;
        
    end
end



myMask = permute(myMask, [3, 1, 2]); 
for i = 1:size(myMask, 3)
    temp_mask = myMask(:, :, i);
    temp_bound = bwboundaries(temp_mask);
    if size(temp_bound) > 0
        
        sum_mask = false(size(temp_mask)); 
        for j = 1:length(temp_bound)
            temp_bound_j = temp_bound{j};
            x = temp_bound_j(: ,2);
            y = temp_bound_j(:, 1);
            x = bmImBumpFiltering1(x, nPixFilter);
            y = bmImBumpFiltering1(y, nPixFilter);
            
            sum_mask = sum_mask | roipoly(temp_mask, x, y); 
        end 
        myMask(:, :, i) = sum_mask;
        
    end
end
myMask = permute(myMask, [2, 3, 1]);




myMask = permute(myMask, [2, 3, 1]); 
for i = 1:size(myMask, 3)
    temp_mask = myMask(:, :, i);
    temp_bound = bwboundaries(temp_mask);
    if size(temp_bound) > 0
        
        sum_mask = false(size(temp_mask)); 
        for j = 1:length(temp_bound)
            temp_bound_j = temp_bound{j};
            x = temp_bound_j(: ,2);
            y = temp_bound_j(:, 1);
            x = bmImBumpFiltering1(x, nPixFilter);
            y = bmImBumpFiltering1(y, nPixFilter);
            
            sum_mask = sum_mask | roipoly(temp_mask, x, y); 
        end 
        myMask(:, :, i) = sum_mask;
        
    end
end
myMask = permute(myMask, [3, 1, 2]);




end