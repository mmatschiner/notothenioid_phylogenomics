# m_matschiner Tue Apr 14 11:08:53 CEST 2020

mafft_loci_dir=../res/mafft/loci
manual_aa_loci_dir=../res/manual/loci

# Set the sequence archive file.
nucl_archive=../data/notothen-phylo-families.fna.tar

# Uncompress all sequence files.
rm -rf FNA
tar -xf ${nucl_archive}
for gznucl in FNA/*.fna.gz
do
	gunzip ${gznucl}
done

# Make alignments of nucleotide sequences on the basis of the aligned amino acid sequences.
for manual_fasta in ${manual_aa_loci_dir}/EOG????????.fasta
do
	fasta_id=`basename ${manual_fasta%.fasta}`
	mafft_aa_fasta=${mafft_loci_dir}/${fasta_id}.fasta
	original_nucl_fasta=FNA/${fasta_id}.fna
	aligned_nucl_fasta=${mafft_loci_dir}/${fasta_id}_nucl.fasta
	if [ ! -f ${aligned_nucl_fasta} ]
	then
		echo -n "Aligning nucleotide alignment ${fasta_id}.fasta..."
		ruby make_nucl_alignments.rb ${mafft_aa_fasta} ${original_nucl_fasta} ${aligned_nucl_fasta}
		echo " done."
	fi
done

# Clean up.
rm -rf FNA

# Transfer the curation from the curated amino acid alignment to the nucleotide alignment.
for manual_fasta in ${manual_aa_loci_dir}/EOG????????.fasta
do
	fasta_id=`basename ${manual_fasta%.fasta}`
	curated_aa_fasta=${manual_aa_loci_dir}/${fasta_id}.fasta
	aligned_nucl_fasta=${mafft_loci_dir}/${fasta_id}_nucl.fasta
	curated_nucl_fasta=${mafft_loci_dir}/${fasta_id}_nucl_curated.fasta
	if [ ! -f ${curated_nucl_fasta} ]
	then
		echo -n "Transferring the curation from file ${curated_aa_fasta}..."
		ruby transfer_alignment_curation.rb ${curated_aa_fasta} ${aligned_nucl_fasta} ${curated_nucl_fasta}
		echo " done."
	fi
done
