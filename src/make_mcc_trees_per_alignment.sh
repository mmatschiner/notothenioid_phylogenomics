# m_matschiner Wed Apr 15 11:20:11 CEST 2020

# If java is not available try loading it as a module.
java_available=`which java | wc -l | tr -d " "`
if [[ ${java_available} == 0 ]]
then
    module load Java/11.0.2
fi

# If rscript is not available try loading it as a module.
rscript_available=`which rscript | wc -l | tr -d " "`
if [[ ${rscript_available} == 0 ]]
then
    module load R/3.6.2-foss-2019b
fi

# Generate a maximum-clade-credibility consensus tree for each alignment.
for trees_with_path in ../res/alignments/05/*/*.trees
do
    trees_id=`basename ${trees_with_path%.trees}`
    cd ../res/alignments/05/${trees_id}
    trees=${trees_id}.trees
    tre=${trees_id}.tre
    if [ ! -f ${tre} ]
    then
        beast/bin/treeannotator -burnin 10 -heights mean ${trees} ${tre}
    fi
    cd - &> /dev/null
done

# Convert each consensus tree to newick format.
for tre in ../res/alignments/05/*/*.tre
do
    nwk=${tre%.tre}.nwk
    Rscript convert_nexus_tree_to_newick.r ${tre} ${nwk}
done