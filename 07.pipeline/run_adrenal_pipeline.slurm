#!/bin/bash
#SBATCH -N 2
#SBATCH -p RM-shared
#SBATCH -t 1-00:00:00
#SBATCH --job-name=adrenal_pipeline
#SBATCH -A bio230007p
#SBATCH --output=07.pipeline/run_adrenal_pipeline.%j.out
#SBATCH --error=07.pipeline/run_adrenal_pipeline.%j.err
#SBATCH --export=ALL

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${repo_root}"

bash 07.pipeline/run_adrenal_pipeline.sh "$@"
