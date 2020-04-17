# m_matschiner Tue Apr 14 17:56:02 CEST 2020

# Get the command line arguments.
bbaa_file_name = ARGV[0]
combine_file_name = ARGV[1]
exclude_species_file_name = ARGV[2]
output_file_name = ARGV[3]

# Read the bbaa file.
bbaa_file = File.open(bbaa_file_name)
bbaa_lines = bbaa_file.readlines

# Read the combine file.
combine_file = File.open(combine_file_name)
combine_lines = combine_file.readlines

# Read the exclude file.
exclude_species_ids = []
exclude_species_file = File.open(exclude_species_file_name)
exclude_species_lines = exclude_species_file.readlines
exclude_species_lines.each { |s| exclude_species_ids << s.strip }

# Filter the bbaa lines.
bbaa_lines_filtered = []
bbaa_lines.each do |l|
	line_ary = l.split
	exclude_line = true if exclude_species_ids.include?(line_ary[0])
	exclude_line = true if exclude_species_ids.include?(line_ary[1])
	exclude_line = true if exclude_species_ids.include?(line_ary[2])
	bbaa_lines_filtered << l unless exclude_line
end

# Prepare the output string and add c numbers.
output_string = ""
bbaa_lines_filtered[1..-1].each do |l1|
	line_ary = l1.split
	bbaa_sp1 = line_ary[0]
	bbaa_sp2 = line_ary[1]
	bbaa_sp3 = line_ary[2]
	cs = []
	combine_lines.each do |l2|
		line_ary = l2.split
		combine_sp1 = line_ary[0]
		combine_sp2 = line_ary[1]
		combine_sp3 = line_ary[2]
		if [bbaa_sp1, bbaa_sp2, bbaa_sp3].sort == [combine_sp1, combine_sp2, combine_sp3].sort
			cs << line_ary[3].to_i
			cs << line_ary[4].to_i
			cs << line_ary[5].to_i
			break
		end
	end
	if cs == []
		puts "ERROR: Trio #{bbaa_sp1}, #{bbaa_sp2}, #{bbaa_sp3} could not be found in combine file!"
		exit 1
	end
	cs.sort!
	output_string << l1.strip
	output_string << "\t#{cs[2]}\t#{cs[1]}\t#{cs[0]}\n"
end

# Write the output file.
output_file = File.open(output_file_name, "w")
output_file.write(output_string)
