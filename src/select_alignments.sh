# m_matschiner Thu Nov 15 21:16:33 CET 2018

# Make results directories, and make sure that they are empty.
for dataset_type in full permissive strict
do
    mkdir -p ../res/alignments/${dataset_type}
    rm -f ../res/alignments/${dataset_type}/*
done

# Convert all alignments from directory 02 to nexus format.
for fasta in ../res/alignments/02/*_nucl.fasta
do
    fasta_id=`basename ${fasta%_nucl.fasta}`
    nexus=../res/alignments/full/${fasta_id}.nex
    if [ ! -f ${nexus} ]
    then
        # Replace ambiguous characters.
        rm -f tmp.fasta
        touch tmp.fasta
        while read line
        do
            if [ ${line:0:1} == ">" ]
            then
                echo ${line} >> tmp.fasta
            else
                echo ${line} | sed 's/n/?/g' | sed 's/y/?/g' | sed 's/r/?/g' | sed 's/m/?/g' | sed 's/s/?/g' | sed 's/w/?/g' | sed 's/k/?/g' | sed 's/b/?/g' | sed 's/h/?/g' >> tmp.fasta
            fi
        done < ${fasta}
        python convert.py tmp.fasta ${nexus} -f nexus
        rm -f tmp.fasta
    fi
done

# Set strict and permissive thresholds.
min_min_ess_strict=100
min_min_ess_permissive=50
max_mut_rate_strict=0.002
max_mut_rate_permissive=0.0025
max_rate_var_strict=0.9
max_rate_var_permissive=1.1

# Read the stats table without header line.
tail -n +2 ../res/tables/alignment_stats.txt > tmp.table.txt
while read line
do
    # Get values from the line.
    align_id=`echo ${line} | tr -s " " | cut -d " " -f 1`
    mut_rate=`echo ${line} | tr -s " " | cut -d " " -f 7`
    rate_var=`echo ${line} | tr -s " " | cut -d " "  -f 8`
    min_ess=`echo ${line} | tr -s " " | cut -d " " -f 9`

    if (( $(echo "${min_ess} > ${min_min_ess_strict}" | bc -l) ))
    then
        if (( $(echo "${mut_rate} < ${max_mut_rate_strict}" | bc -l) ))
        then
            if (( $(echo "${rate_var} < ${max_rate_var_strict}" | bc -l) ))
            then
                if [ ! -f ../res/alignments/strict/${align_id}.nex ]
                then
                    cp -f ../res/alignments/full/${align_id}.nex ../res/alignments/strict
                fi
            fi
        fi
    fi
    if (( $(echo "${min_ess} > ${min_min_ess_permissive}" | bc -l) ))
    then
        if (( $(echo "${mut_rate} < ${max_mut_rate_permissive}" | bc -l) ))
        then
            if (( $(echo "${rate_var} < ${max_rate_var_permissive}" | bc -l) ))
            then
                if [ ! -f ../res/alignments/permissive/${align_id}.nex ]
                then
                    cp -f ../res/alignments/full/${align_id}.nex ../res/alignments/permissive
                fi
            fi
        fi
    fi
done < tmp.table.txt

# Clean up.
rm -f tmp.table.txt
