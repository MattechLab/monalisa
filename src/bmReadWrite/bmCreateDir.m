% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function out = bmCreateDir(argDir, varargin)

myErrorFlag = false;
if length(varargin) > 0
    myErrorFlag = varargin{1} ;
end

out = 1;
if bmCheckDir(argDir, false)
    if myErrorFlag
        errordlg('The directory already exists !');
    end
    out = 0;
    return;
end

mkdir(argDir);

if not(bmCheckDir(argDir,0))
    errordlg('Unable to creat the directory');
    out = 0;
    return;
end