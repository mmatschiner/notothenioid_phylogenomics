# m_matschiner Sun Apr 12 12:24:13 CEST 2020

# Make the results directories.
mkdir -p ../res/mafft/loci
mkdir -p ../res/manual/loci

# Set the sequence archive file.
aa_archive=../data/notothen-phylo-families.faa.tar

# Uncompress all sequence files.
tar -xf ${aa_archive}
for gzaa in FAA/*.faa.gz
do
	gunzip ${gzaa}
done

# Generate alignments for all sequence files.
for aa in FAA/*.faa
do
	aa_id=`basename ${aa%.faa}`
	mafft --auto ${aa} > ../res/mafft/loci/${aa_id}.fasta
done

# Clean up.
rm -rf FAA

# Copy the alignment files.
cp ../res/mafft/loci/*.fasta ../res/manual/loci

# Give directions.
echo "Next, curate each alignment in ../res/manual/loci manually."