

% 
% Berk Can Acikgoz
% University of Bern and Insel Spital
% Bern - Switzerland
% February 2025
% 


function phi = HarmonicField3D(coeffs, X, Y, Z)
% coeffs: 15x1 vector of basis coefficients
% X, Y, Z: 3D grids from ndgrid
% phi: result scalar field of same size as X/Y/Z

    if numel(coeffs) ~= 15
        error('Expected 15 coefficients');
    end

    r2 = X.^2 + Y.^2 + Z.^2;  % radial term

    % Basis functions
    B = cell(15,1);
    B{1}  = ones(size(X));                      % 1
    B{2}  = X;                                  % x
    B{3}  = Y;                                  % y
    B{4}  = Z;                                  % z
    B{5}  = X .* Y;                             % xy
    B{6}  = X .* Z;                             % xz
    B{7}  = Y .* Z;                             % yz
    B{8}  = X.^2 - Y.^2;                        % x^2 - y^2
    B{9}  = 2 * Z.^2 - X.^2 - Y.^2;             % 2z^2 - x^2 - y^2
    B{10} = X .* (5 * Z.^2 - r2);               % x(5z^2 - r^2)
    B{11} = Y .* (5 * Z.^2 - r2);               % y(5z^2 - r^2)
    B{12} = Z .* (5 * Z.^2 - 3 * r2);           % z(5z^2 - 3r^2)
    B{13} = X .* Y .* Z;                        % xyz
    B{14} = X.^3 - 3 * X .* Y.^2;               % x^3 - 3xy^2
    B{15} = Y.^3 - 3 * X.^2 .* Y;               % y^3 - 3x^2y

    % Weighted sum
    phi = zeros(size(X));
    for i = 1:15
        phi = phi + coeffs(i) * B{i};
    end
end