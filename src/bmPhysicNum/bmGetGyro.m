% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function [out varargout] = bmGetGyro(argString, varargin)

% Arg string is the name of an element. Ex : 'Na' or '23Na'.
% Varargin accepts 'Hz' or 'Rad' or nothing.
% out = gyromagnetic_ratio in Rad Hz / T or in Hz / T. 
% Varargout = [unit, element_name].

HzFlag = false;

if length(varargin) > 0
    if strcmp(varargin{1}, 'Hz')
        HzFlag = true;
    elseif strcmp(varargin{1}, 'Rad')
        HzFlag = false;
    end
end

switch argString
    case '1H'
        out = 267.513;
        varargout{2} = '1H';
    case '3He'
        out = -203.789;
        varargout{2} = '3He';
    case '7Li'
        out = 103.962;
        varargout{2} = '7Li';
    case '13C'
        out = 67.262;
        varargout{2} = '13C';
    case '19F'
        out = 251.662;
        varargout{2} = '19F';
    case '23Na'
        out = 70.761;
        varargout{2} = '23Na';
    case '27Al'
        out = 69.763;
        varargout{2} = '27Al';
    case '31P'
        out = 108.291;
        varargout{2} = '31P';
    case '63Cu'
        out = 71.118;
        varargout{2} = '63Cu';
        
        
    case 'H'
        out = 267.513;
        varargout{2} = '1H';
    case 'He'
        out = -203.789;
        varargout{2} = '3He';
    case 'Li'
        out = 103.962;
        varargout{2} = '7Li';
    case 'C'
        out = 67.262;
        varargout{2} = '13C';
    case 'F'
        out = 251.662;
        varargout{2} = '19F';
    case 'Na'
        out = 70.761;
        varargout{2} = '23Na';
    case 'Al'
        out = 69.763;
        varargout{2} = '27Al';
    case 'P'
        out = 108.291;
        varargout{2} = '31P';
    case 'Cu'
        out = 71.118;
        varargout{2} = '63Cu';
    otherwise
        error('Wrong list of arguments.');
end

out = out*10^6; 
if HzFlag
    out = out/(2*pi);
end

if HzFlag
    varargout{1} = 'Hz / T';
else
    varargout{1} = 'Rad / T / s';
end


end