# m_matschiner Tue Apr 14 13:21:55 CEST 2020

# Get the command line arguments.
curated_aa_fasta_file_name = ARGV[0]
aligned_nucl_fasta_file_name = ARGV[1]
curated_nucl_fasta_file_name = ARGV[2]

# Read the mafft alignment of amino acid sequences.
curated_aa_ids = []
curated_aa_seqs = []
curated_aa_fasta_file = File.open(curated_aa_fasta_file_name)
curated_aa_fasta_lines = curated_aa_fasta_file.readlines
curated_aa_fasta_lines.each do |l|
	if l[0] == ">"
		curated_aa_ids << l[1..-1].strip
		curated_aa_seqs << ""
	elsif l.strip != ""
		curated_aa_seqs.last << l.strip
	end
end

# Read the aligned nucleotide sequences.
aligned_nucl_ids = []
aligned_nucl_seqs = []
aligned_nucl_fasta_file = File.open(aligned_nucl_fasta_file_name)
aligned_nucl_fasta_lines = aligned_nucl_fasta_file.readlines
aligned_nucl_fasta_lines.each do |l|
	if l[0] == ">"
		aligned_nucl_ids << l[1..-1].strip
		aligned_nucl_seqs << ""
	elsif l.strip != ""
		aligned_nucl_seqs.last << l.strip
	end
end

# Make sure that the ids are identical.
unless curated_aa_ids == aligned_nucl_ids
	puts "ERROR: IDs differ!"
	exit 1
end

# Transfer the curation.
curated_nucl_seqs = []
aligned_nucl_ids.size.times do |x|
	curated_nucl_seq = ""
	curated_aa_seqs[x].size.times do |pos|
		if curated_aa_seqs[x][pos] == "-"
			curated_nucl_seq << "---"
		else
			curated_nucl_seq << aligned_nucl_seqs[x][(3*pos)..((3*pos)+2)]
		end
	end
	curated_nucl_seqs << curated_nucl_seq
end

# Prepare the curated versions of the nucleotide sequences fasta file.
curated_nucl_fasta_string = ""
aligned_nucl_ids.size.times do |x|
	curated_nucl_fasta_string << ">#{aligned_nucl_ids[x]}\n"
	curated_nucl_fasta_string << "#{curated_nucl_seqs[x]}\n"
end

# Write the curated versions of the nucleotide sequences fasta file.
curated_nucl_fasta_file = File.open(curated_nucl_fasta_file_name, "w")
curated_nucl_fasta_file.write(curated_nucl_fasta_string)
