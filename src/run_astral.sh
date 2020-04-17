# m_matschiner Tue Apr 14 15:41:37 CEST 2020

# Make the results directory.
mkdir -p ../res/astral

# Download astral.
if [ ! -d ../bin/Astral ]
then
	wget https://github.com/smirarab/ASTRAL/raw/master/Astral.5.7.3.zip
	unzip Astral.5.7.3.zip
	rm Astral.5.7.3.zip
	mv Astral ../bin
fi

# Make species trees for all three datasets with astral.
for dataset_type in full strict permissive
do
	# Run astral.
	java -jar -Xmx8G ../bin/Astral/astral.5.7.3.jar -i ../res/iqtree/${dataset_type}/loci.treefile -o ../res/astral/${dataset_type}.tre
done