# m_matschiner Tue Apr 14 11:22:50 CEST 2020

class String
	def to_aa(frame=1)
		nucl_string = self[frame-1..-1]
		n_aas = nucl_string.size/3
		nucl_string = nucl_string[0..(n_aas*3)]
		aa_string = ""
		f_nucls = ["TTT", "TTC"]
		l_nucls = ["TTA", "TTG", "CTT", "CTC", "CTA", "CTG"]
		i_nucls = ["ATT", "ATC", "ATA"]
		m_nucls = ["ATG"]
		v_nucls = ["GTT", "GTC", "GTA", "GTG"]
		s_nucls = ["TCT", "TCC", "TCA", "TCG", "AGT", "AGC"]
		p_nucls = ["CCT", "CCC", "CCA", "CCG"]
		t_nucls = ["ACT", "ACC", "ACA", "ACG"]
		a_nucls = ["GCT", "GCC", "GCA", "GCG"]
		y_nucls = ["TAT", "TAC"]
		__nucls = ["TAA", "TAG", "TGA"]
		h_nucls = ["CAT", "CAC"]
		q_nucls = ["CAA", "CAG"]
		n_nucls = ["AAT", "AAC"]
		k_nucls = ["AAA", "AAG"]
		d_nucls = ["GAT", "GAC"]
		e_nucls = ["GAA", "GAG"]
		c_nucls = ["TGT", "TGC"]
		w_nucls = ["TGG"]
		r_nucls = ["CGT", "CGC", "CGA", "CGG", "AGA", "AGG"]
		g_nucls = ["GGT", "GGC", "GGA", "GGG"]
		while nucl_string.size > 2
			codon_triplet = nucl_string.slice!(0..2)
			aa = ""
			aa = "F" if f_nucls.include?(codon_triplet.upcase)
			aa = "L" if l_nucls.include?(codon_triplet.upcase)
			aa = "I" if i_nucls.include?(codon_triplet.upcase)
			aa = "M" if m_nucls.include?(codon_triplet.upcase)
			aa = "V" if v_nucls.include?(codon_triplet.upcase)
			aa = "S" if s_nucls.include?(codon_triplet.upcase)
			aa = "P" if p_nucls.include?(codon_triplet.upcase)
			aa = "T" if t_nucls.include?(codon_triplet.upcase)
			aa = "A" if a_nucls.include?(codon_triplet.upcase)
			aa = "Y" if y_nucls.include?(codon_triplet.upcase)
			aa = "*" if __nucls.include?(codon_triplet.upcase)
			aa = "H" if h_nucls.include?(codon_triplet.upcase)
			aa = "Q" if q_nucls.include?(codon_triplet.upcase)
			aa = "N" if n_nucls.include?(codon_triplet.upcase)
			aa = "K" if k_nucls.include?(codon_triplet.upcase)
			aa = "D" if d_nucls.include?(codon_triplet.upcase)
			aa = "E" if e_nucls.include?(codon_triplet.upcase)
			aa = "C" if c_nucls.include?(codon_triplet.upcase)
			aa = "W" if w_nucls.include?(codon_triplet.upcase)
			aa = "R" if r_nucls.include?(codon_triplet.upcase)
			aa = "G" if g_nucls.include?(codon_triplet.upcase)
			aa = "-" if codon_triplet == "---"
			aa = "X" if codon_triplet.upcase.include?("N")
			aa = "X" if codon_triplet.upcase.include?("Y")
			aa = "X" if codon_triplet.upcase.include?("R")
			aa = "X" if codon_triplet.upcase.include?("M")
			aa = "X" if codon_triplet.upcase.include?("S")
			aa = "X" if codon_triplet.upcase.include?("W")
			aa = "X" if codon_triplet.upcase.include?("K")
			aa = "X" if codon_triplet.upcase.include?("B")
			aa = "X" if codon_triplet.upcase.include?("H")
			if aa == ""
				puts "ERROR: Unexpected triplet: #{codon_triplet}!"
				exit 1
			end
			aa_string += aa
		end
		aa_string.chomp!("*")
		aa_string.gsub("*","X")
	end
end

# Get the command line arguments.
mafft_aa_fasta_file_name = ARGV[0]
original_nucl_fasta_file_name = ARGV[1]
aligned_nucl_fasta_file_name = ARGV[2]

# Read the mafft alignment of amino acid sequences.
mafft_aa_ids = []
mafft_aa_seqs = []
mafft_aa_fasta_file = File.open(mafft_aa_fasta_file_name)
mafft_aa_fasta_lines = mafft_aa_fasta_file.readlines
mafft_aa_fasta_lines.each do |l|
	if l[0] == ">"
		mafft_aa_ids << l[1..-1].strip
		mafft_aa_seqs << ""
	elsif l.strip != ""
		mafft_aa_seqs.last << l.strip
	end
end

# Read the original nucleotide sequences.
original_nucl_ids = []
original_nucl_seqs = []
original_nucl_fasta_file = File.open(original_nucl_fasta_file_name)
original_nucl_fasta_lines = original_nucl_fasta_file.readlines
original_nucl_fasta_lines.each do |l|
	if l[0] == ">"
		original_nucl_ids << l[1..-1].strip
		original_nucl_seqs << ""
	elsif l.strip != ""
		original_nucl_seqs.last << l.strip
	end
end

# Make sure that the ids are identical in both files.
unless mafft_aa_ids.size == original_nucl_ids.size
	puts "ERROR: Numbers of fasta IDs differ: #{mafft_aa_ids.size}, #{original_nucl_ids.size}!"
	exit 1
end
mafft_aa_ids.size.times do |x|
	unless mafft_aa_ids[x] == original_nucl_ids[x]
		puts "ERROR: Fasta IDs differ: #{mafft_aa_ids[x]}, #{original_nucl_ids[x]}!"
		exit 1
	end
end

# Make sure that all of the aligned sequences are the same length.
mafft_aa_ids.size.times do |x|
	unless mafft_aa_seqs[x].size == mafft_aa_seqs[0].size
		puts "ERROR: Different sequence lengths!"
		exit 1
	end
end

# Make sure that the nucl sequences are three times as long as the aligned aa sequences without gaps.
mafft_aa_ids.size.times do |x|
	n_aas = mafft_aa_seqs[x].gsub("-","").size
	n_nucls = original_nucl_seqs[x].size
	unless n_nucls/3 == n_aas or n_nucls/3 == n_aas+1
		puts "ERROR: Sequence lengths don't correspond: #{n_nucls}, #{n_aas}!"
		exit 1
	end
end

# Align the nucleotide sequences.
aligned_nucl_seqs = []
mafft_aa_ids.size.times do |x|
	aa_frame1 = original_nucl_seqs[x].to_aa(frame = 1)
	aa_frame2 = original_nucl_seqs[x].to_aa(frame = 2)
	aa_frame3 = original_nucl_seqs[x].to_aa(frame = 3)
	# Make sure that the translations differ from each other.
	if aa_frame1 == aa_frame2 or aa_frame1 == aa_frame3 or aa_frame2 == aa_frame3
		puts "ERROR: Two translations are identical!"
		exit 1
	end
	# Make sure that the translated nucl sequences are identical to the aa sequences.
	mafft_aa_seq_without_gaps = mafft_aa_seqs[x].gsub("-","")
	unless [aa_frame1, aa_frame2, aa_frame3].include?(mafft_aa_seq_without_gaps)
		puts "ERROR: Translated nucleotide sequences differs from amino acid sequence:"
		exit 1
	end
	# Determine the frame.
	frame = 1 if aa_frame1 == mafft_aa_seq_without_gaps
	frame = 2 if aa_frame2 == mafft_aa_seq_without_gaps
	frame = 3 if aa_frame3 == mafft_aa_seq_without_gaps
	nucl = original_nucl_seqs[x][frame-1..-1]
	nucl = nucl[0..(3*mafft_aa_seq_without_gaps.size)]
	# Prepare a nucleotide sequence with gaps.
	nucl_with_gaps = ""
	aa_index = 0
	mafft_aa_seqs[x].size.times do |pos|
		if mafft_aa_seqs[x][pos] == "-"
			nucl_with_gaps += "---"
		else
			nucl_with_gaps += nucl[(aa_index*3)..((aa_index*3)+2)]
			aa_index += 1
		end
	end
	aligned_nucl_seqs << nucl_with_gaps
end

# Once again verify that the aligned nucleotide sequences correspond exactly to the aligned amino acids.
aligned_nucl_seqs.size.times do |x|
	unless aligned_nucl_seqs[x].to_aa == mafft_aa_seqs[x]
		puts "ERROR: After adding gaps, translations are no longer identical!"
		exit 1
	end
end

# Prepare the fasta file with aligned nucleotide sequences.
aligned_nucl_fasta_string = ""
aligned_nucl_seqs.size.times do |x|
	aligned_nucl_fasta_string << ">#{original_nucl_ids[x]}\n"
	aligned_nucl_fasta_string << "#{aligned_nucl_seqs[x]}\n"
end

# Write the fasta file with aligned nucleotide sequences.
aligned_nucl_fasta_file = File.open(aligned_nucl_fasta_file_name, "w")
aligned_nucl_fasta_file.write(aligned_nucl_fasta_string)
