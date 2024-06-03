% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function bmDispPercent(varargin)

N = fix(nargin/3);

s = [];

count = 0;
for i = 1:N
    
    count = count + 1;
    x = varargin{count};
    
    count = count + 1;
    y = varargin{count};
    
    count = count + 1;
    z = varargin{count};
    
    s = [s, num2str(round(x/y*100)), ' % of ', z, '   '];
    
end

disp(s);

end

