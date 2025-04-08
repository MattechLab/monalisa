function out = bmGetNum(varargin)
% out = bmGetNum(varargin)
%
% This function opens a input prompt asking for a number. The returned
% value can also be an array if the input contains , and ;.
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
%   varargin{1}: String or char containing the prompt asking for one or 
%    multiple numbers. Default is 'Enter a number : '.
%
% Returns:
%   out: A number or an array that the user put in. Otherwise contains 0.
    
    % Extract optional arguments
    prompt = bmVarargin(varargin);
    
    % Set default value
    if isempty(prompt) | (~isstring(prompt) & ~ischar(prompt))
        prompt = 'Enter a number : ';
    end
    
    % Prompt user for input
    myAnswer = inputdlg(prompt, 'bmGetNum',[1 40]);     
    
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
    
    % Turn answer to number
    myAnswer = str2num(myAnswer{1}); 
    
    % Test if input is valid
    if isempty(myAnswer)
       out = 0; 
       return;  
    end
    
    % Return valid answer (0 otherwise)
    out = myAnswer; 
     
end