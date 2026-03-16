function export_parity_images(resultsDir, contextName, C_array_prime, C, x, y_ref, C_ref)
%EXPORT_PARITY_IMAGES Save intermediate outputs for Python parity comparison.
%   resultsDir: directory where outputs are written
%   contextName: base name for the run (e.g. 'coilSensitivityEstimation')

if nargin < 6
    error('export_parity_images:MissingInputs', 'C_array_prime, C, x, y_ref and C_ref are required.');
end

outDir = fullfile(resultsDir, 'parity');
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

matFile = fullfile(outDir, [contextName, '_parity.mat']);
save(matFile, 'C_array_prime', 'C', 'x', 'y_ref', 'C_ref');

% pick representative 2D slices for quick PNG check (middle z slice)
z = max(1, round(size(C, 3) / 2));

Cprime_mag = abs(C_array_prime(:, :, z, :));
C_mag = abs(C(:, :, z, :));
x_mag = abs(x(:, :, z, :));

% Combine channel info by max projection as small preview
Cprime_img = squeeze(max(Cprime_mag, [], 4));
C_img = squeeze(max(C_mag, [], 4));
x_img = squeeze(max(x_mag, [], 4));

imwrite(apply_uint8(Cprime_img), fullfile(outDir, [contextName, '_Cprime.png']));
imwrite(apply_uint8(C_img), fullfile(outDir, [contextName, '_C.png']));
imwrite(apply_uint8(x_img), fullfile(outDir, [contextName, '_x.png']));

fprintf('export_parity_images: saved %s and PNG previews in %s\n', matFile, outDir);
end

function out = apply_uint8(im)
if ~isreal(im)
    im = abs(im);
end
mn = min(im(:));
mx = max(im(:));
if mx > mn
    out = uint8(255 * (im - mn) / (mx - mn));
else
    out = uint8(im);
end
end
