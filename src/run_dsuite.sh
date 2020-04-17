# m_matschiner Tue Apr 14 17:17:15 CEST 2020

# Download dsuite.
if [ ! -f ../bin/Dsuite ]
then
	git clone https://github.com/millanek/Dsuite.git
	cd Dsuite
	make
	cd -
	mv Dsuite/Build/Dsuite ../bin
	rm -rf Dsuite
fi

# Make the results directory.
mkdir -p ../res/dsuite

# Convert the concatenated alignment to vcf format.
python convert.py ../res/iqtree/full/full.nex tmp.vcf -f vcf_bi

# Make the sets file.
species_table=../data/species.tab
tail -n +2 ${species_table} | cut -f 1 > tmp.table1.txt
tail -n +2 ${species_table} | cut -f 1 | sed 's/P_magn/Outgroup/g' > tmp.table2.txt
paste tmp.table1.txt tmp.table2.txt > tmp.sets.txt

# Run dsuite.
if [ ! -f ../res/dsuite/BBAA.txt ]
then
	../bin/Dsuite Dtrios tmp.vcf tmp.sets.txt
	# Sort the output files.
	for out in tmp.sets__*.txt
	do
		out_id=`echo ${out%.txt} | sed 's/tmp.sets__//g'`
		mv ${out} ../res/dsuite/${out_id}.txt
	done
fi

# Postprocess the dsuite results.
bbaa=../res/dsuite/BBAA.txt
combine=../res/dsuite/combine.txt
echo -e "EleMac\nBovDia\nBovVar\nCotGob\nG_acul\nS_nigr\nP_fluv\nH_come\nP_magn\nT_rubr\nA_test\nM_arma\nA_call\nO_lati" > tmp.excl.txt
bbaa_filtered=../res/dsuite/BBAA_filtered.txt
if [ ! -f ${bbaa_filtered} ]
then
	ruby postprocess_dsuite.rb ${bbaa} ${combine} tmp.excl.txt ${bbaa_filtered}
fi

# Clean up.
rm -f tmp.table1.txt
rm -f tmp.table2.txt
rm -f tmp.sets.txt
rm -f tmp.excl.txt
rm -f tmp.vcf