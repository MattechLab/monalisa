@ECHO OFF

pushd %~dp0

REM Run codespell to check for typos interactively
IF "%1"=="check_typos" (
    codespell -w -i 3 -I .\rst\codespell_ignore.txt .\rst
    EXIT /B 0
)

REM Run generate_rst.py before building the documentation
IF "%1"=="generate" (
    python .\rst\generate_rst.py
    EXIT /B 0
)

REM Set Sphinx build variables
IF "%SPHINXBUILD%"=="" (
    SET SPHINXBUILD=sphinx-build
)
SET SOURCEDIR=.\rst
SET BUILDDIR=_build

REM Check if Sphinx is installed
%SPHINXBUILD% >NUL 2>NUL
IF ERRORLEVEL 9009 (
    ECHO.
    ECHO The 'sphinx-build' command was not found. Make sure you have Sphinx
    ECHO installed, then set the SPHINXBUILD environment variable to point
    ECHO to the full path of the 'sphinx-build' executable. Alternatively you
    ECHO may add the Sphinx directory to PATH.
    ECHO.
    ECHO If you don't have Sphinx installed, grab it from
    ECHO https://www.sphinx-doc.org/
    EXIT /B 1
)

REM Default to showing help if no argument is provided
IF "%1"=="" GOTO help

REM Run codespell and generate before building documentation
codespell -w -i 3 -I .\rst\codespell_ignore.txt .\rst
python .\rst\generate_rst.py

REM Build the specified Sphinx target
%SPHINXBUILD% -M %1 %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%
GOTO end

:help
%SPHINXBUILD% -M help %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%

:end
popd
