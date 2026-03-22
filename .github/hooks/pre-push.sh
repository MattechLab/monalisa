#!/bin/bash
#
# Pre-push: unit tests + optional parity snapshot generation for monalisa_py.
#
# Parity outputs are git-friendly by default (see tests/ci/save_parity_snapshot.m):
#   - fingerprints.json : SHA-256 per array (compare across forks without huge blobs)
#   - data.mat.gz       : only variables under MONALISA_PARITY_MAX_VARIABLE_BYTES
#
# Environment (examples):
#   MONALISA_SKIP_PRE_PUSH_PARITY=1     — skip parity generation entirely (still runs tests)
#   MONALISA_GENERATE_PARITY_STEPS=coil,binnings — skip mitosius + recon on low-RAM machines
#   MONALISA_PARITY_MAT_POLICY=full     — legacy: put every variable in data.mat (large)
#   MONALISA_PARITY_MAX_VARIABLE_BYTES=104857600 — raise per-variable MAT budget (bytes)
#
# RAM: MATLAB cannot force OS swap. On Windows, increase the page file if you OOM;
# on Linux, ensure enough swap and optionally raise vm.swappiness. Splitting steps
# (MONALISA_GENERATE_PARITY_STEPS) reduces how much must stay in memory at once.
#
echo "Running MATLAB tests before push..."

REPO_ROOT=$(git rev-parse --show-toplevel)

export MONALISA_MITOSIUS_BINNING=allLines

# Run MATLAB in batch mode
matlab -batch "
    cd('$REPO_ROOT');
    addpath(genpath('./tests'));
    addpath(genpath('./demo'));
    addpath(genpath('./third_party'));
    addpath('./third_part/twix_for_monalisa/');
    addpath(genpath('./src'));
    compile_mex_for_monalisa;
    try
        cd('$REPO_ROOT/demo/script_demo/script_tutorial_1/');
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

if [ -n "$MONALISA_SKIP_PRE_PUSH_PARITY" ]; then
    echo "Skipping parity generation (MONALISA_SKIP_PRE_PUSH_PARITY is set). Push allowed."
    exit 0
fi

echo "MATLAB tests passed. Running demo-driven parity data generation..."

matlab -batch "
    cd('$REPO_ROOT');
    addpath(genpath('./tests'));
    addpath(genpath('./demo'));
    addpath(genpath('./third_party'));
    addpath('./third_part/twix_for_monalisa/');
    addpath(genpath('./src'));
    addpath('./demo/script_demo/script_tutorial_1/');
    compile_mex_for_monalisa;
    try
        cd('$REPO_ROOT/demo/script_demo/script_tutorial_1/');
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
