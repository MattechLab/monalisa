#!/bin/bash

echo "Running MATLAB tests before push..."

# Go to the root of the monalisa repo
cd $(git rev-parse --show-toplevel) || exit 1

# Run MATLAB in batch mode
matlab -batch "
    addpath(genpath('./tests'));
    addpath(genpath('./demo'));
    addpath(genpath('./third_party'));
    addpath('./third_part/twix_for_monalisa/');
    addpath(genpath('./src'));
    try
        run_all_tests;
        exit(0);
    catch ME
        disp(getReport(ME));
        exit(1);
    end
"
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "MATLAB tests failed. Push aborted."
    exit 1
fi

echo "MATLAB tests passed. Running demo-driven parity data generation..."

matlab -batch "
    addpath(genpath('./tests'));
    addpath(genpath('./demo'));
    addpath(genpath('./third_party'));
    addpath('./third_part/twix_for_monalisa/');
    addpath(genpath('./src'));
    try
        generate_parity_data;
        exit(0);
    catch ME
        disp(getReport(ME));
        exit(1);
    end
"
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "MATLAB parity data generation failed. Push aborted."
    exit 1
fi

echo "All pre-push checks passed. Parity data generated for monalisa_py comparison. Proceeding with push."
exit 0
