# m_matschiner Fri Apr 17 23:24:01 CEST 2020

# Get the total numbers of amino acids in all alignments before and after manual curation.
n_aas=`cat ../res/mafft/loci/EOG????????.fasta | sed 's/[^A-Z]//g' | tr -d "\n" | wc -c`
n_aas_curated=`cat ../res/manual/loci/EOG????????.fasta | sed 's/[^A-Z]//g' | tr -d "\n" | wc -c`

# Get the difference.
n_aas_removed=`echo "${n_aas}-${n_aas_curated}" | bc -l`

# Report the numbers of amino acids before and after curation.
echo "Number of amino acids before curation: ${n_aas}" > ../res/tables/curation_stats.txt
echo "Number of amino acids after curation: ${n_aas_curated}" >> ../res/tables/curation_stats.txt
echo "Number of amino acids removed in curation: ${n_aas_removed}" >> ../res/tables/curation_stats.txt