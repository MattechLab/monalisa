function out = bmGetNat(varargin)
% out = bmGetNat(varargin)
%
% This function opens a input prompt asking for a natural number.
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Contributors:
%   Dominik Helbing (Documentation & Comments)
%   MattechLab 2024
%
% Parameters:
%   varargin{1}: String or char containing the prompt asking for one 
%    number. Default is 'Enter a natural number : '.
%
% Returns:
%   out: A number that the user put in. Otherwise contains 0.
    
    % Extract optional arguments
    prompt = bmVarargin(varargin);
    
    % Set default value
    if isempty(prompt) | (~isstring(prompt) & ~ischar(prompt))
        prompt = 'Enter a natural number : ';
    end
    
    % Prompt user for input
    myAnswer = inputdlg({prompt}, 'bmGetNnat',[1 40]);     
    
    % Test if input is valid
    if isempty(myAnswer)
       out = 0; 
       return; 
    end
    
    % Test if input is valid
    if isempty(myAnswer{1})
       out = 0; 
       return; 
    end
    
    % Test if input is valid
    myAnswer = str2num(myAnswer{1}); 
    
    % Test if input is valid
    if isempty(myAnswer)
       out = 0; 
       return;  
    end

    % Test if input is valid (don't allow arrays)
    if length(myAnswer) > 1
       out = 0; 
       return; 
    end
    
    % Test if input is valid
    out = fix(abs(myAnswer)); 
     
     
end