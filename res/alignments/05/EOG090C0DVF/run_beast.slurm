#!/bin/bash

# m_matschiner Wed Apr 15 00:22:32 CEST 2020

# Job name:
#SBATCH --job-name=EOG090C0DVF
#
# Project:
#SBATCH --account=nn9244k
#
# Wall clock limit:
#
#SBATCH --time=70:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=2G
#
# Outfile:
#SBATCH --output=EOG090C0DVF.out

## Set up job environment:
## Set up the job environment
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
module --quiet purge  # Reset the modules to the system default
java_available=`which java | wc -l | tr -d " "`
if [[ ${java_available} == 0 ]]
then
    module load Java/11.0.2
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
if [ ! -f EOG090C0DVF.log ]
then
    beast/bin/beast -seed ${RANDOM} EOG090C0DVF.xml
else
    beast/bin/beast -seed ${RANDOM} -resume EOG090C0DVF.xml
fi
