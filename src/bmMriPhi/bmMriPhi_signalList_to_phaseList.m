% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myPhase = bmMriPhi_signalList_to_phaseList(s)

s_x         =  s; 
s_y         =  s_x - circshift(s_x, [0, 1]); 
s_y(:, 1)   =  s_y(:, 2); 
s_y         = -s_y; 

myNumList = []; 

for i = 1:size(s, 1)
    
   temp_s = s_x(i, :); 
   temp_s = temp_s(:)' - mean(temp_s(:));
   temp_s = temp_s/std(temp_s(:)); 
   s_x(i, :) = temp_s; 
   
   temp_s = s_y(i, :); 
   temp_s = temp_s(:)' - mean(temp_s(:));
   temp_s = temp_s/std(temp_s(:)); 
   s_y(i, :) = temp_s; 
   
   
   figure
   hold on
   plot(s_x(i, :), s_y(i, :), '.-')
   title(num2str(i))
   axis image
   uiwait; 
   
   myAnswer = bmYesNo; 
   if myAnswer
        myNumList = cat(1, myNumList, i); 
   end
   
end

s_x = s_x(myNumList, :); 
s_y = s_y(myNumList, :); 

myPhase = angle(complex(s_x, s_y)); 

end