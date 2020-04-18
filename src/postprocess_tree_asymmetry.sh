# michaelm Thu Mar 19 00:16:28 CET 2020

# Load modules if necessary.
ruby_available=`which ruby | wc -l | tr -d " "`
if [[ ${ruby_available} == 0 ]]
then
    module load Ruby/2.6.3-GCCcore-8.2.0
fi

# Make the result directories.
mkdir -p ../res/tables
mkdir -p ../res/plots

# Get the likelihoods for the three topologies per hypothesis.
table=../res/tables/tree_asymmetry.txt
if [ ! -f ${table} ]
then
    echo -e "gene_id\tbest\tdelta_lik\tlik_t1\tlik_t2\tlik_t3" >> ${table}
    for nex in ../res/alignments/full/*.nex
    do
        alignment_id=`basename ${nex%.nex} | cut -d "_" -f 1`
        
        # Test if all three iqtree info files exist.
        t1_file=../res/tree_asymmetry/${alignment_id}_constraint1.info.txt
        t2_file=../res/tree_asymmetry/${alignment_id}_constraint2.info.txt
        t3_file=../res/tree_asymmetry/${alignment_id}_constraint3.info.txt
        if [[ -s ${t1_file} && -s ${t2_file} && -s ${t3_file} ]]
        then

            # Make sure that all files contain likelihoods.
            for t_file in ${t1_file} ${t2_file} ${t3_file}
            do
                lik_included=`cat ${t_file} | grep "Log-likelihood of the tree" | wc -l`
                if [[ ${lik_included} == 0 ]]
                then
                    echo "ERROR: No likelihood found in file ${t_file}!"
                    exit 1
                fi
            done

            # Get the three likelihoods.
            t1_lik=`cat ${t1_file} | grep "Log-likelihood of the tree" | cut -d ":" -f 2 | cut -d " " -f 2`
            t2_lik=`cat ${t2_file} | grep "Log-likelihood of the tree" | cut -d ":" -f 2 | cut -d " " -f 2`
            t3_lik=`cat ${t3_file} | grep "Log-likelihood of the tree" | cut -d ":" -f 2 | cut -d " " -f 2`
            
            # Determine the best and second-best likelihood, and their difference.
            best_lik=`echo -e "${t1_lik}\n${t2_lik}\n${t3_lik}" | sort -n -r | head -n 1`
            second_best_lik=`echo -e "${t1_lik}\n${t2_lik}\n${t3_lik}" | sort -n -r | head -n 2 | tail -n 1`
            delta_lik=`echo "${best_lik} - ${second_best_lik}" | bc`
            if (( 1 == `echo "${t1_lik} > ${t2_lik}" | bc` )) && (( 1 == `echo "${t1_lik} > ${t3_lik}" | bc` ))
            then
                echo -e "${alignment_id}\tt1\t${delta_lik}\t${t1_lik}\t${t2_lik}\t${t3_lik}" >> ${table}
            elif (( 1 == `echo "${t2_lik} > ${t1_lik}" | bc` )) && (( 1 == `echo "${t2_lik} > ${t3_lik}" | bc` ))
            then
                echo -e "${alignment_id}\tt2\t${delta_lik}\t${t1_lik}\t${t2_lik}\t${t3_lik}" >> ${table}
            elif (( 1 == `echo "${t3_lik} > ${t1_lik}" | bc` )) && (( 1 == `echo "${t3_lik} > ${t2_lik}" | bc` ))
            then
                echo -e "${alignment_id}\tt3\t${delta_lik}\t${t1_lik}\t${t2_lik}\t${t3_lik}" >> ${table}
            fi
        fi
    done
fi

# Plot results for likelihood comparisons.
table=../res/tables/tree_asymmetry.txt
plot=../res/plots/tree_asymmetry.svg
if [ ! -f ${plot} ]
then
    ruby plot_constrained_likelihoods.rb ${table} ${plot}
fi
