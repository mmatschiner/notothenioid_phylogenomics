# michaelm Wed Jun 17 15:14:05 CEST 2020

# Load modules.
module load Beast/2.5.2-GCC-8.2.0-2.31.1
module load Ruby/2.6.3-GCCcore-8.2.0
module load Python/3.7.2-GCCcore-8.2.0

# Combine results for each set of beast analyses.
for dataset in full permissive strict
do
    # Combine replicate log files for the beast analyses.
    mkdir -p ../res/beast/${dataset}/partitioned/combined
    ls ../res/beast/${dataset}/partitioned/replicates/r??/*.log > ../res/beast/${dataset}/partitioned/combined/logs.txt
    ls ../res/beast/${dataset}/partitioned/replicates/r??/*.trees > ../res/beast/${dataset}/partitioned/combined/trees.txt
    python3 logcombiner.py -n 1000 -b 20 ../res/beast/${dataset}/partitioned/combined/logs.txt ../res/beast/${dataset}/partitioned/combined/${dataset}.log
    python3 logcombiner.py -n 1000 -b 20 ../res/beast/${dataset}/partitioned/combined/trees.txt ../res/beast/${dataset}/partitioned/combined/${dataset}.trees

    # Make maximum-clade-credibility consensenssus trees.
    treeannotator -b 0 -heights mean ../res/beast/${dataset}/partitioned/combined/${dataset}.trees ../res/beast/${dataset}/partitioned/combined/${dataset}.tre
done
