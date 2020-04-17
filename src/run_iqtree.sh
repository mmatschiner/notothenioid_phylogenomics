# m_matschiner Tue Apr 14 14:23:10 CEST 2020

# Analyse all three datasets with iqtree.
for dataset_type in full permissive strict
do
	# Make the results directory.
	alignment_dir=../res/alignments/${dataset_type}
	iqtree_dir=../res/iqtree/${dataset_type}
	mkdir ${iqtree_dir}

	# Concatenate all per-locus nexus files.
	concatenated=${iqtree_dir}/${dataset_type}.nex
	if [ ! -f ${concatenated} ]
	then
	    ruby concatenate.rb -i ${alignment_dir}/*.nex -o ${concatenated} -f nexus -p
	fi

	# Run iqtree.
	iqtree -nt 8 -s ${concatenated} -p ${concatenated} -m GTR+G --prefix concat -bb 1000
	iqtree -nt 8 -s ${concatenated} -S ${concatenated} -m GTR+G --prefix loci
	iqtree -t concat.treefile --gcf loci.treefile -s ${concatenated} -m GTR+G --scf 100 --prefix concord

	# Move the iqtree results files.
	mv concat.* ${iqtree_dir}
	mv loci.* ${iqtree_dir}
	mv concord.* ${iqtree_dir}
done
