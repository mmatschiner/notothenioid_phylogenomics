# m_matschiner Sat Apr 18 13:33:23 CEST 2020

# Download iqtree.
if [ ! -f ../bin/iqtree ]
then
	if [[ "$OSTYPE" == "linux-gnu" ]]
	then
		wget https://github.com/Cibiv/IQ-TREE/releases/download/v2.0-rc2/iqtree-2.0-rc2-Linux.tar.gz
		tar -xzf iqtree-2.0-rc2-Linux.tar.gz
		mv iqtree-2.0-rc2-Linux/bin/iqtree ../bin
		rm -f iqtree-2.0-rc2-Linux.tar.gz
		rm -rf iqtree-2.0-rc2-Linux
	elif [[ "$OSTYPE" == "darwin"* ]]
	then
		wget https://github.com/Cibiv/IQ-TREE/releases/download/v2.0-rc2/iqtree-2.0-rc2-MacOSX.zip
		tar -xzf iqtree-2.0-rc2-MacOSX.zip
		mv iqtree-2.0-rc2-MacOSX/bin/iqtree ../bin
		rm iqtree-2.0-rc2-MacOSX.zip
		rm -rf iqtree-2.0-rc2-MacOSX
	fi
fi

# Set the directory with locus alignments.
alignment_dir=../res/alignments/full

# Set the tree directory.
res_dir=../res/tree_asymmetry

# Make the tree directory.
mkdir -p ${res_dir}

out="P_magn,H_come,O_lati,T_rubr,A_call,M_arma,A_test,S_nigr,G_acul,P_fluv,CotGob,BovVar,BovDia,EleMac"
gr1="PleAnt"
gr2="DisMaw,PatGun,LepSqu,LepNud,LepLar,TreSco,TreLoe,TreHan,TreBer"
gr3="GobGib,NotRos,HarKer,HarAnt,ArtSko,HisVel,DolLon,VomInf,BatMar,AkaNud,GymAcu,PseGeo,PagMac,ChaWil,ChaAce,CryAnt,ChiDew"
echo "(${out},${gr1},(${gr2},${gr3}));" > tmp.constraint1.tre
echo "(${out},${gr3},(${gr1},${gr2}));" > tmp.constraint2.tre
echo "(${out},${gr2},(${gr1},${gr3}));" > tmp.constraint3.tre

# Check if slurm is available and run iqtree.
slurm_available=`which squeue | wc -l | tr -d " "`
if [[ ${slurm_available} == "1" ]]
then
    sbatch run_iqtree_constrained.slurm ${alignment_dir} tmp.constraint1.tre tmp.constraint2.tre tmp.constraint3.tre ${res_dir}
else
    bash run_iqtree_constrained.sh ${alignment_dir} tmp.constraint1.tre tmp.constraint2.tre tmp.constraint3.tre ${res_dir}
fi
