% Bastien Milani
% CHUV and UNIL
% Lausanne - Switzerland
% May 2023

function cData = bmBinary2Array_cData(argDir, argFileName_real, argFileName_imag)

tempData_real = bmBinary2Array(argDir, argFileName_real);
tempData_imag = bmBinary2Array(argDir, argFileName_imag);
cData         = complex(tempData_real, tempData_imag);

end