# m_matschiner Tue Apr 14 15:58:51 CEST 2020

# Make the result directory.
mkdir -p ../res/nj

# Download and make rapidnj.
if [ ! -f ../bin/rapidnj ]
then
    wget https://users-birc.au.dk/cstorm/software/rapidnj/rapidnj-src-2.3.2.tar.gz
    tar -xzf rapidnj-src-2.3.2.tar.gz
    rm -f rapidnj-src-2.3.2.tar.gz
    cd rapidNJ
    make
    cd -
    mv rapidNJ/bin/rapidnj ../bin
    rm -rf rapidNJ
fi

# Make neighbor-joining trees for all three datasets with rapidnj.
for dataset_type in full strict permissive
do
    # Make a distance matrix from the alignment.
    nexus=../res/iqtree/${dataset_type}/${dataset_type}.nex
    distances_matrix=../res/nj/${dataset_type}.phy
    if [ ! -f ${distances_matrix} ]
    then
        ruby make_distance_matrix_from_nexus.rb -i ${nexus} -o ${distances_matrix}
    fi

    # Run rapidnj with distances precalculated.
    ../bin/rapidnj ${distances_matrix} > ../res/nj/${dataset_type}_corrected_p_distances.tre

    # Convert the concatenated alignment to stockholm format.
    python convert.py ${nexus} tmp.phy -f phylip
    echo "# STOCKHOLM 1.0" > tmp.sth
    tail -n +2 tmp.phy >> tmp.sth
    echo "//" >> tmp.sth

    # Run rapidnj directly with the alignment.
    ../bin/rapidnj tmp.sth > ../res/nj/${dataset_type}_kimura.tre
    ../bin/rapidnj -a jc tmp.sth > ../res/nj/${dataset_type}_jukes_cantor.tre

    # Clean up.
    rm -f tmp.phy
    rm -f tmp.sth
done