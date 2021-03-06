#!/bin/bash -e

#SBATCH -J panel
#SBATCH -A ACORG-SL2-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake
#SBATCH --time=10:00:00

srun -n 1 panel.sh "$@"
