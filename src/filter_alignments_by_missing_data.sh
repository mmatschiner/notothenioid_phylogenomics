# m_matschiner Tue Apr 14 20:07:47 CEST 2020

# Make the output directory if it doesn't exist yet.
mkdir -p ../res/alignments/03
rm -f ../res/alignments/03/*

# Filter alignments by their completeness.
ruby filter_alignments_by_missing_data.rb ../res/alignments/02 ../res/alignments/03 38 500