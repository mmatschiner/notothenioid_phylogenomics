# m_matschiner Sun Apr 12 12:41:41 CEST 2020

# Uncompress all amino acid alignments and place them in a directory for manual curation.
bash prepare_aa_alignments_for_manual_check.sh

# Manually curate all amino acid alignments.
exit

# Find out how many sites were set to missing in the manual curation.
bash quantify_manual_changes.sh

# Transfer the curation to the nucleotide sequence alignments.
bash prepare_nucl_alignments.sh

# Make a set of alignments from which high-entropy or -gap sites are removed.
bash filter_sites_with_BMGE.sh

# Make a reduced set of alignments with no more than 3 missing sequences and a minimum length of 500 bp.
bash filter_alignments_by_missing_data.sh

# Make a reduced set of alignment from which outliers in GC-content variation are removed.
bash filter_alignments_by_GC_content_variation.sh

# Run beast analyses for each alignment.
bash run_beast_per_alignment.sh

# Wait for all beast analyses to finish.
exit

# Generate maximum-clade-credibility summary trees for each alignment.
bash make_mcc_trees_per_alignment.sh

# Clean up from beast analyses.
bash clean_beast_output.sh

# Get basic statistics for each alignment and summarize the rate and rate variation per alignment.
bash get_alignment_stats.sh

# Select alignments according to different thresholds.
bash select_alignments.sh

# Infer concatenated and per-locus maximum-likelihood trees with iqtree.
bash run_iqtree.sh

# Use iqtree phylogenies for species tree inference with astral.
bash run_astral.sh

# Generate neighbor-joining phylogenies with rapidnj.
bash run_nj.sh

# Test for introgression with dsuite.
bash run_dsuite.sh

# Run iqtree analyses with constraints to analyze tree asymmetry.
bash analyze_tree_asymmetry.sh

# Summarize the results of the constrained iqtree analyses.
bash postprocess_tree_asymmetry.sh

# Find partitions using partitionfinder.
bash find_partitions.sh

# Concatenate partitions defined with partitionfinder.
bash concatenate_partitions.sh

# Run a set of beast analyses based on concatenation.
bash run_concatenated_beast_analyses.sh

# Combine the results of replicate beast analyses, and generate mcc trees.
bash combine_beast_results.sh
