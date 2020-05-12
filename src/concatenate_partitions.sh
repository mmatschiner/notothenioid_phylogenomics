# m_matschiner Tue May 12 17:21:22 CEST 2020

# Load modules if necessary.
ruby_available=`which ruby | wc -l | tr -d " "`
if [[ ${ruby_available} == 0 ]]
then
    module load Ruby/2.6.3-GCCcore-8.2.0
fi

# Concatenate alignments according to partitionfinder results.
for dataset_type in full strict permissive
do
	mkdir -p ../res/partitionfinder/${dataset_type}/partitions
    cat ../res/partitionfinder/${dataset_type}/analysis/analysis/best_scheme.txt | grep EOG | grep -v Scheme_cleaned_scheme | cut -d "|" -f 5 | tr -d " " > tmp.pf.txt
    count=0
    while read line
    do
        (( count = ${count} + 1 ))
        if [ ! -f ../res/partitionfinder/${dataset_type}/partitions/partition_${count}.nex ]
        then
            mkdir -p tmp
            partition_ids=`echo ${line} | tr "," "\n"`
            for partition_id in ${partition_ids}
            do
                cp ../res/partitionfinder/${dataset_type}/alignments/${partition_id}.nex tmp
            done
            ruby concatenate.rb -i tmp/*.nex -o ../res/partitionfinder/${dataset_type}/partitions/partition_${count}.nex -f nexus
            rm -r tmp
        fi
    done < tmp.pf.txt
    rm -f tmp.pf.txt
done
