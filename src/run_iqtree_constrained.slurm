#!/bin/bash

# michaelm Wed Mar 18 10:39:12 CET 2020

# Job name:
#SBATCH --job-name=iqtrec
#
# Project:
#SBATCH --account=nn9244k
#
# Log file.
#SBATCH --out=../res/tree_asymmetry/slurm.out
# Wall clock limit:
#SBATCH --time=10:00:00
#
# Processor and memory usage:
#SBATCH --ntasks-per-node=4
#SBATCH --mem-per-cpu=2G

## Set up job environment:
set -o errexit  # Exit the script on any error
set -o nounset  # Treat any unset variables as an error
module --quiet purge  # Reset the modules to the system default
module load Python/3.6.6-foss-2018b
module list

# Get command line arguments.
alignment_dir=${1}
constraint1=${2}
constraint2=${3}
constraint3=${4}
res_dir=${5}

# Run iqtree.
for nex in ${alignment_dir}/*.nex
do
    alignment_id=`basename ${nex%.nex} | cut -d "_" -f 1`
    for constraint_tree in ${constraint1} ${constraint2} ${constraint3}
    do
        constraint_id=`basename ${constraint_tree%.tre} | sed 's/tmp.//g'`
        info=${res_dir}/${alignment_id}_${constraint_id}.info.txt
        if [ ! -f ${info} ]
        then
            python convert.py ${nex} tmp.iqtree.phy -f phylip -m 0.9

            # Copy the constraint tree to the temporary directory.
            cp -f ${constraint_tree} tmp.constraint.tre

            # Remove taxa from the constraint tree that don't occur in the alignment.
            cat tmp.constraint.tre | tr -d "(" | tr -d ")" | tr -d ";" | tr "," "\n" | sed "/^$/d" | sort > tmp.taxa_in_constraint_tree.txt
            cat tmp.iqtree.phy | tail -n +2 | cut -d " " -f 1 | sort > tmp.taxa_in_align.txt
        
            taxa_missing_in_align=`comm -23 tmp.taxa_in_constraint_tree.txt tmp.taxa_in_align.txt`
            for taxon in ${taxa_missing_in_align}
            do
                cat tmp.constraint.tre | sed "s/${taxon}//g" | sed "s/,,/,/g" | sed "s/,)/)/g" | sed "s/(,/(/g" > tmp.constraint2.tre
                mv -f tmp.constraint2.tre tmp.constraint.tre
            done

            # Check that at least four taxa remain in the alignment and tree.
            insufficient_align_found=0
            n_taxa_in_align=`cat tmp.taxa_in_align.txt | wc -l`
            if (( ${n_taxa_in_align} < 4 ))
            then
                insufficient_align_found=1
            else
                n_uniq_seqs_in_align=`cat tmp.iqtree.phy | tail -n +2 | tr -s " " | cut -d " " -f 2 | sort | uniq | wc -l`
                if (( ${n_uniq_seqs_in_align} < 4 ))
                then
                    insufficient_align_found=1
                fi
            fi

            # Check if a constraint now includes just a single taxon.
            insufficient_constraint_found=0
            for taxon in `cat tmp.taxa_in_align.txt`
            do
                this_insufficient_constraint_found=`cat tmp.constraint.tre | grep "(${taxon})" | wc -l`
                if [[ ${this_insufficient_constraint_found} == 1 ]]
                then
                    insufficient_constraint_found=1
                fi
                this_insufficient_constraint_found=`cat tmp.constraint.tre | grep "(${taxon},(" | grep "))" | wc -l`
                if [[ ${this_insufficient_constraint_found} == 1 ]]
                then
                    insufficient_constraint_found=1
                fi
                this_insufficient_constraint_found=`cat tmp.constraint.tre | grep "),${taxon})" | grep "((" | wc -l`
                if [[ ${this_insufficient_constraint_found} == 1 ]]
                then
                    insufficient_constraint_found=1
                fi
            done
            this_insufficient_constraint_found=`cat tmp.constraint.tre | grep "()" | wc -l`
            if [[ ${this_insufficient_constraint_found} == 1 ]]
            then
                insufficient_constraint_found=1
            fi
            this_insufficient_constraint_found=`cat tmp.constraint.tre | grep "((" | grep "))" | wc -l`
            if [[ ${this_insufficient_constraint_found} == 1 ]]
            then
                insufficient_constraint_found=1
            fi

            # Run iqtree.
            if [[ ${insufficient_constraint_found} == 0 && ${insufficient_align_found} == 0 ]]
            then
                ../bin/iqtree -nt 4 -s tmp.iqtree.phy -m GTR -g tmp.constraint.tre --runs 2 -quiet
                mv -f tmp.iqtree.phy.iqtree ${info}
            else
                touch ${info}
            fi

            # Clean up.
            rm -f tmp.iqtree.*
            rm -f tmp.constraint.tre
            rm -f tmp.taxa_in_constraint_tree.txt
            rm -f tmp.taxa_in_align.txt

        fi
    done
done
