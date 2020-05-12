# m_matschiner Tue May 12 10:17:53 CEST 2020

# Get the command-line arguments.
dir=${1}

# Run partitionfinder.
../bin/partitionfinder-2.1.1/PartitionFinder.py -r -p 4 --min-subset-size 5000 --weights 1,1,1,1 ${dir}