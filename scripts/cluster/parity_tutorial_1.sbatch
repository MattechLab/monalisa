#!/bin/bash
#SBATCH --job-name=monalisa_parity
#SBATCH --output=slurm_parity_%j.out
#SBATCH --error=slurm_parity_%j.err
# Tune for your site (examples; replace with your partition/QoS):
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=128G
#SBATCH --time=04:00:00
#
# Run from the cluster:   sbatch scripts/cluster/parity_tutorial_1.sbatch
# Or with env overrides:  SBATCH_MEM=256G sbatch ...
#
# Prerequisites:
#   - MATLAB on the node (module load ... or full path to matlab)
#   - Repo checkout with tutorial data (data_8_tutorial_1) present or downloadable
#   - Valid MATLAB license for batch (network license / SLURM integration per your site)
#
# After the job: commit updated parity/ from this checkout (or rsync back to your laptop).

set -euo pipefail

REPO_ROOT="${MONALISA_REPO_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
cd "$REPO_ROOT"

export MONALISA_MITOSIUS_BINNING="${MONALISA_MITOSIUS_BINNING:-allLines}"
export MONALISA_GENERATE_PARITY_STEPS="${MONALISA_GENERATE_PARITY_STEPS:-coil,binnings,mitosius,recon}"
export MONALISA_PARITY_MAT_POLICY="${MONALISA_PARITY_MAT_POLICY:-split}"
export MONALISA_PARITY_GZIP="${MONALISA_PARITY_GZIP:-1}"

MATLAB_BIN="${MATLAB_BIN:-matlab}"

echo "REPO_ROOT=$REPO_ROOT"
echo "Steps=$MONALISA_GENERATE_PARITY_STEPS"

"$MATLAB_BIN" -nodisplay -nosplash -batch "
    cd('$REPO_ROOT');
    addpath(genpath('./tests'));
    addpath(genpath('./demo'));
    addpath(genpath('./third_party'));
    addpath('./third_part/twix_for_monalisa/');
    addpath(genpath('./src'));
    addpath('./demo/script_demo/script_tutorial_1/');
    try
        compile_mex_for_monalisa;
    catch ME
        warning('compile_mex_for_monalisa failed: %s', ME.message);
    end
    generate_parity_data;
"

echo "Parity generation finished. Inspect $REPO_ROOT/parity then git add/commit as needed."
