function myTwix = bmTwix(argFile)
% myTwix = bmTwix(argFile)
%
% Extracts the Twix object as a struct from a Siemens raw data file
%
% Authors:
%   Bastien Milani
%   CHUV and UNIL
%   Lausanne - Switzerland
%   May 2023
%
% Parameters:
%   argFile (char): A string with the path to the data file
%
% Returns:
%   myTwix (struct): A struct containing the extracted Twix object

myTwix = mapVBVD_JH_for_monalisa(argFile);
if iscell(myTwix)
    myTwix = myTwix{end};
end

end