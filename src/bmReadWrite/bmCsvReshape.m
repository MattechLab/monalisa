% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmCsvReshape(argArray, argSize)


out = zeros(argSize);

	for i = 1:length(argArray(:))/argSize(1)/argSize(2)
		out(:,:,i) = argArray((i-1)*argSize(1)+1:i*argSize(1), :);
	end

out = reshape(out, argSize);

end %end of function