#!/bin/bash

# m_matschiner Wed Apr 15 00:22:32 CEST 2020

# Job name:
#SBATCH --job-name=full
#
# Project:
#SBATCH --account=nn9244k
#
# Wall clock limit:
#
#SBATCH --time=168:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=5
#SBATCH --mem-per-cpu=2G
#
# Outfile:
#SBATCH --output=full.out

## Set up job environment:
## Set up the job environment
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
module --quiet purge  # Reset the modules to the system default
java_available=`which java | wc -l | tr -d " "`
if [[ ${java_available} == 0 ]]
then
    module load beagle-lib/3.1.2-GCC-8.2.0-2.31.1
fi

# Download and install beast.
if [ ! -f beast/bin/beast ]
then
	wget https://github.com/CompEvol/beast2/releases/download/v2.6.2/BEAST.v2.6.2.Linux.tgz
	tar -xzf BEAST.v2.6.2.Linux.tgz
	rm -f BEAST.v2.6.2.Linux.tgz
fi

# Make sure the bModelTest package is installed.
bmt_installed=`beast/bin/packagemanager -list | grep bModelTest | cut -d "|" -f 2 | tr -d " "`
if [[ ${bmt_installed} == "NA" ]]
then
	beast/bin/packagemanager -add bModelTest
fi

## Run or resume beast analysis.
if [ ! -f full.log ]
then
    beast/bin/beast -threads 5 -seed ${RANDOM} -beagle full.xml
else
    beast/bin/beast -threads 5 -seed ${RANDOM} -beagle -resume full.xml
fi
