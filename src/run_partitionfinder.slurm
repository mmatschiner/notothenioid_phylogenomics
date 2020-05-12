#!/bin/bash

# m_matschiner Sat Nov 24 18:25:40 CET 2018

# Job name:
#SBATCH --job-name=partfi
#
# Project:
#SBATCH --account=nn9244k
#
# Wall clock limit:
#SBATCH --time=100:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=5
#SBATCH --mem-per-cpu=4G

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
module --quiet purge  # Reset the modules to the system default
module load Python/3.6.6-foss-2018b
module list

# Get the command-line arguments.
dir=${1}

# Run partitionfinder.
../bin/partitionfinder-2.1.1/PartitionFinder.py -r -p 4 --min-subset-size 5000 --weights 1,1,1,1 ${dir}