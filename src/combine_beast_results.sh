# michaelm Wed Jun 17 15:14:05 CEST 2020

# Load modules if necessary.
ruby_available=`which ruby | wc -l | tr -d " "`
if [[ ${ruby_available} == 0 ]]
then
    module load Ruby/2.6.3-GCCcore-8.2.0
fi
beast_available=`which treeannotator | wc -l | tr -d " "`
if [[ ${beast_available} == 0 ]]
then
    module load Beast/2.5.2-GCC-8.2.0-2.31.1
fi
python_available=`which python | wc -l | tr -d " "`
if [[ ${python_available} == 0 ]]
then
    module load Python/3.7.2-GCCcore-8.2.0
fi

# Combine results for each set of beast analyses.
for dataset in full permissive strict
do
	for model in HKY GTR
	do
		# Combine log files of unppartitioned analyses.
		model_lower=`echo ${model} | tr '[:upper:]' '[:lower:]'`
		mkdir -p ../res/beast/${dataset}/unpartitioned/${model_lower}/combined
		ls ../res/beast/${dataset}/unpartitioned/${model_lower}/replicates/r??/*.log > ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/logs.txt
		ls ../res/beast/${dataset}/unpartitioned/${model_lower}/replicates/r??/*.trees > ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/trees.txt
		python3 logcombiner.py -n 2000 -b 20 ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/logs.txt ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}.log
		python3 logcombiner.py -n 10000 -b 0 ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}.log ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}_10000.log
		python3 logcombiner.py -n 2000 -b 20 ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/trees.txt ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}.trees
		python3 logcombiner.py -n 10000 -b 0 ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}.trees ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}_10000.trees

		# Make maximum-clade-credibility consensenssus trees for unpartitioned analyses.
		treeannotator -b 0 -heights mean ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}_10000.trees ../res/beast/${dataset}/unpartitioned/${model_lower}/combined/${dataset}.tre
	done

	# Combine log files of ppartitioned analyses.
	model_lower=`echo ${model} | tr '[:upper:]' '[:lower:]'`
	mkdir -p ../res/beast/${dataset}/partitioned/gtr/combined
	ls ../res/beast/${dataset}/partitioned/gtr/replicates/r??/*.log > ../res/beast/${dataset}/partitioned/gtr/combined/logs.txt
	ls ../res/beast/${dataset}/partitioned/gtr/replicates/r??/*.trees > ../res/beast/${dataset}/partitioned/gtr/combined/trees.txt
	python3 logcombiner.py -n 2000 -b 20 ../res/beast/${dataset}/partitioned/gtr/combined/logs.txt ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}.log
	python3 logcombiner.py -n 10000 -b 0 ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}.log ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}_10000.log
	python3 logcombiner.py -n 2000 -b 20 ../res/beast/${dataset}/partitioned/gtr/combined/trees.txt ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}.trees
	python3 logcombiner.py -n 10000 -b 0 ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}.trees ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}_10000.trees

	# Make maximum-clade-credibility consensenssus trees for partitioned analyses.
	treeannotator -b 0 -heights mean ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}_10000.trees ../res/beast/${dataset}/partitioned/gtr/combined/${dataset}.tre

done
