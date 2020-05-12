# m_matschiner Tue May 12 09:56:51 CEST 2020

# Download partitionfinder.
if [ -f partitionfinder-2.1.1 ]
then
    wget https://github.com/brettc/partitionfinder/archive/v2.1.1.tar.gz
    tar -xzf v2.1.1.tar.gz
    rm v2.1.1.tar.gz
    cd partitionfinder-2.1.1
    make
    cd - &> /dev/null
    mv partitionfinder-2.1.1 ../bin
fi
chmod +x ../bin/partitionfinder-2.1.1/PartitionFinder.py

# Split alignments by codon position.
for mode in full strict permissive
do
    mkdir -p ../res/partitionfinder/${mode}/alignments
    for nex in ../res/alignments/${mode}/*.nex
    do
        gene_id=`basename ${nex%.nex}`
        ruby split_by_cp.rb -i ${nex}
        rm ../res/alignments/${mode}/${gene_id}_3.nex
        mv ../res/alignments/${mode}/${gene_id}_1.nex ../res/partitionfinder/${mode}/alignments
        mv ../res/alignments/${mode}/${gene_id}_2.nex ../res/partitionfinder/${mode}/alignments
    done
done

# Prepare the partitionfinder analyses.
for mode in full strict permissive
do
    # Make the analysis directory.
    mkdir -p ../res/partitionfinder/${mode}/analysis

    # Write the concatenated alignment file and a partitions file.
    ruby concatenate.rb -i ../res/partitionfinder/${mode}/alignments/*.nex -o tmp.align_with_parts.phy -f phylip -p &> /dev/null
    n_tax=`head -n 1 tmp.align_with_parts.phy | cut -d " " -f 1`
    n_lines=$(( ${n_tax} + 1 ))
    head -n ${n_lines} tmp.align_with_parts.phy > ../res/partitionfinder/${mode}/analysis/${mode}.phy
    n_lines=$(( ${n_lines} + 2 ))
    tail -n +${n_lines} tmp.align_with_parts.phy | sed "s/DNA, //g" | sed "s/=/ = /g" | sed 's/$/;/' > tmp.parts.phy

    # Write the partitionfinder configuration file.
    cfg=../res/partitionfinder/${mode}/analysis/partition_finder.cfg
    echo "# ALIGNMENT FILE #" > ${cfg}
    echo "alignment = ${mode}.phy;" >> ${cfg}
    echo "" >> ${cfg}
    echo "# BRANCHLENGTHS #" >> ${cfg}
    echo "branchlengths = linked;" >> ${cfg}
    echo "" >> ${cfg}
    echo "# MODELS OF EVOLUTION #" >> ${cfg}
    echo "models = GTR+G;" >> ${cfg}
    echo "model_selection = aic;" >> ${cfg}
    echo "" >> ${cfg}
    echo "# DATA BLOCKS #" >> ${cfg}
    echo "[data_blocks]" >> ${cfg}
    cat tmp.parts.phy >> ${cfg}
    echo "" >> ${cfg}
    echo "# SCHEMES #" >> ${cfg}
    echo "[schemes]" >> ${cfg}
    echo "search = rcluster;" >> ${cfg}
done

# Check if slurm is available and run partitionfinder.
slurm_available=`which squeue | wc -l | tr -d " "`
if [[ ${slurm_available} == "1" ]]
then
    for mode in full strict permissive
    do
        out=../res/partitionfinder/${mode}/slurm.out
        rm -f ${out}
        sbatch -o ${out} run_partitionfinder.slurm ../res/partitionfinder/${mode}/analysis
    done
else
    for mode in full strict permissive
    do
        bash run_partitionfinder.sh ../res/partitionfinder/${mode}/analysis
    done
fi
