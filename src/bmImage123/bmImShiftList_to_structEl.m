% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function myStructEl = bmImShiftList_to_structEl(argShiftList)

myStructEl = strel(bmImShiftList_to_image(argShiftList)); 

if not(isequal(argShiftList, myStructEl.getneighbors))
   error('There was a problem converting imShiftList to structEl. '); 
   return; 
end

end