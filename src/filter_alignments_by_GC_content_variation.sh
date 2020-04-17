# m_matschiner Sun Jul 22 15:15:26 CEST 2018

# Make the output directory.
mkdir -p ../res/alignments/04
rm -f ../res/alignments/04/*

# Remove alignments that are outliers in gc-content variation.
ruby filter_alignments_by_GC_content_variation.rb ../res/alignments/03 ../res/alignments/04 0.03