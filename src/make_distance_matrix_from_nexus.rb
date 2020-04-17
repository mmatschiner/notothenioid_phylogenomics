# m_matschiner Tue Apr 14 16:58:14 CEST 2020

## This script reads a nexus file and produces a matrix of pairwise distances.

# Define the help string.
help_string = ""
help_string << "\n"
help_string << "get_pairwise_dists_from_nexus.rb\n"
help_string << "\n"
help_string << "Available options:\n"
help_string << "  Option   Value                    Comment\n"
help_string << "  -i       input file name        | Nexus file name\n"
help_string << "  -o       output file name       | Output file name\n"
help_string << "\n"

# Read the arguments.
if ARGV == [] or ["-h","--help","-help"].include?(ARGV[0].downcase)
    puts help_string
    exit
end

# Read the specified input file name.
if ARGV.include?("-i")
    input_file_name = ARGV[ARGV.index("-i")+1]
else
    puts "ERROR: An input file name must be given with option \"-i\"!"
    exit 1
end

# Read the specified output file name.
if ARGV.include?("-o")
    dist_matrix_file_name = ARGV[ARGV.index("-o")+1]
else
    puts "ERROR: An input file name must be given with option \"-o\"!"
    exit 1
end

# Initiate arrays for alignment ids.
ids = []
seqs = []

# Read the nexus file.
file = File.open(input_file_name)
lines = file.readlines
unless lines[0].strip.downcase == "#nexus"
    puts "ERROR: File is not in NEXUS format: #{input_file_name}!"
    exit 1
end
in_matrix = false
lines.each do |l|
    l.strip!
    if l.downcase == "matrix"
        in_matrix = true
    elsif l == ";"
        in_matrix = false
    elsif l != "" and in_matrix
        ids << l.split[0]
        seqs << l.split[1].upcase
    end
end
seqs.each do |s|
    if s.size != seqs[0].size
        puts "ERROR! Two sequences have different lengths!"
        exit 1
    end
end
if ids.uniq != ids
    puts "ERROR! Not all IDs are unique in file #{input_file_name}!"
    exit 1
end

# Get pairwise sequence divergences.
dist_matrix = []
ids.size.times do
    dist_row = []
    ids.size.times do
        dist_row << 0
    end
    dist_matrix << dist_row
end
0.upto(ids.size-2) do |x|
    (x+1).upto(ids.size-1) do |y|
        n_identical = 0
        n_different = 0
        seqs[x].size.times do |pos|
            if ["A","C","G","T"].include?(seqs[x][pos]) and ["A","C","G","T"].include?(seqs[y][pos])
                if seqs[x][pos] == seqs[y][pos]
                    n_identical += 1
                else
                    n_different += 1
                end
            elsif ["A","C","G","T"].include?(seqs[x][pos]) and ["R","Y","S","W","K","M"].include?(seqs[y][pos])
                if seqs[y][pos] == "R" and ["A","G"].include?(seqs[x][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[y][pos] == "Y" and ["C","T"].include?(seqs[x][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[y][pos] == "S" and ["G","C"].include?(seqs[x][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[y][pos] == "W" and ["A","T"].include?(seqs[x][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[y][pos] == "K" and ["G","T"].include?(seqs[x][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[y][pos] == "M" and ["A","C"].include?(seqs[x][pos])
                    n_identical += 0.5
                    n_different += 0.5
                else
                    n_different += 1
                end
            elsif ["R","Y","S","W","K","M"].include?(seqs[x][pos]) and ["A","C","G","T"].include?(seqs[y][pos])
                if seqs[x][pos] == "R" and ["A","G"].include?(seqs[y][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[x][pos] == "Y" and ["C","T"].include?(seqs[y][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[x][pos] == "S" and ["G","C"].include?(seqs[y][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[x][pos] == "W" and ["A","T"].include?(seqs[y][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[x][pos] == "K" and ["G","T"].include?(seqs[y][pos])
                    n_identical += 0.5
                    n_different += 0.5
                elsif seqs[x][pos] == "M" and ["A","C"].include?(seqs[y][pos])
                    n_identical += 0.5
                    n_different += 0.5
                else
                    n_different += 1
                end
            elsif ["R","Y","S","W","K","M"].include?(seqs[x][pos]) and ["R","Y","S","W","K","M"].include?(seqs[y][pos])
                if seqs[x][pos] == seqs[y][pos]
                    n_identical += 0.5
                    n_different += 0.5
                else
                    n_different += 1
                end
            end
        end
        n_total = n_identical+n_different
        p_different = n_different/n_total.to_f
        dist_matrix[x][y] = p_different
        dist_matrix[y][x] = p_different
    end
end

# Determine the maximum id length.
max_id_length = 0
ids.each do |i|
    max_id_length = i.size if i.size > max_id_length
end

# Prepare the distance matrix string.
dist_matrix_string = "#{ids.size}\n"
ids.size.times do |x|
    dist_matrix_row = "#{ids[x].ljust(max_id_length)}    "
    ids.size.times do |y|
        dist_matrix_row << "#{dist_matrix[x][y].round(5).to_s.ljust(10)}"
    end
    dist_matrix_row.strip!
    dist_matrix_row << "\n"
    dist_matrix_string << dist_matrix_row
end

# Write the output file.
dist_matrix_file = File.open(dist_matrix_file_name, "w")
dist_matrix_file.write(dist_matrix_string)
