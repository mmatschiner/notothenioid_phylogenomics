# m_matschiner Tue Apr 14 14:09:48 CEST 2020

# Make the output directories.
mkdir -p ../res/alignments/01
mkdir -p ../res/alignments/02

# Make the binary directory.
mkdir -p ../bin

# Download BMGE.
wget ftp://ftp.pasteur.fr/pub/gensoft/projects/BMGE/BMGE-1.12.tar.gz
tar -xzf BMGE-1.12.tar.gz
rm -rf BMGE-1.12.tar.gz
mv -f BMGE-1.12/BMGE.jar ../bin
rm -rf BMGE-1.12

# Copy the curated nucleotide fasta files.
for fasta in ../res/mafft/loci/EOG????????_nucl_curated.fasta
do
	fasta_id=`basename ${fasta%_nucl_curated.fasta}`
	cat ${fasta} | cut -d ":" -f 1 > ../res/alignments/01/${fasta_id}_nucl.fasta
done

# Filter sites for missing data and entropy with BMGE.
ruby filter_sites_with_BMGE.rb ../bin/BMGE.jar ../res/alignments/01/ ../res/alignments/02/ 0.2 0.5