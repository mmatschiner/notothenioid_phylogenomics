# m_matschiner Tue Apr 21 10:24:10 CEST 2020

# This script needs the following dependencies.
# convert.py

# Load modules if necessary.
ruby_available=`which ruby | wc -l | tr -d " "`
if [[ ${ruby_available} == 0 ]]
then
    module load Ruby/2.7.1-GCCcore-8.3.0
fi
rscript_available=`which Rscript | wc -l | tr -d " "`
if [[ ${rscript_available} == 0 ]]
then
    module load R/3.6.2-foss-2019b
fi

# Make the output directory.
mkdir -p ../res/beast

# Make a temporary constraints file.
nots="CotGob,BovDia,BovVar,EleMac,DisMaw,LepLar,LepNud,LepSqu,PatGun,TreSco,TreLoe,TreBer,TreHan,PleAnt,GobGib,NotRos,HarAnt,HarKer,ArtSko,DolLon,HisVel,VomInf,AkaNud,BatMar,GymAcu,PagMac,PseGeo,ChaWil,ChaAce,ChiDew,CryAnt"
echo -e "# Gobiaria+Syngnatharia+Pelagiaria+Eupercaria+Ovalentaria+Anabantaria+Carangaria" > tmp.constraints.txt
echo -e "lognormal(0,107.08,0.033)\tcrown\tP_magn,H_come,A_call,O_lati,A_test,M_arma,T_rubr,P_fluv,G_acul,S_nigr,${nots}" >> tmp.constraints.txt
echo -e "# Syngnatharia+Pelagiaria+Eupercaria+Ovalentaria+Anabantaria+Carangaria" >> tmp.constraints.txt
echo -e "lognormal(0,104.48,0.036)\tcrown\tH_come,A_call,O_lati,A_test,M_arma,T_rubr,P_fluv,G_acul,S_nigr,${nots}" >> tmp.constraints.txt
echo -e "# Eupercaria+Ovalentaria+Anabantaria+Carangaria" >> tmp.constraints.txt
echo -e "lognormal(0,101.79,0.033)\tcrown\tA_call,O_lati,A_test,M_arma,T_rubr,P_fluv,G_acul,S_nigr,${nots}" >> tmp.constraints.txt
echo -e "# Ovalentaria+Anabantaria+Carangaria" >> tmp.constraints.txt
echo -e "monophyletic\tNA\tA_call,O_lati,A_test,M_arma" >> tmp.constraints.txt
echo -e "# Ovalentaria" >> tmp.constraints.txt
echo -e "monophyletic\tNA\tA_call,O_lati" >> tmp.constraints.txt
echo -e "# Anabantaria" >> tmp.constraints.txt
echo -e "monophyletic\tNA\tA_test,M_arma" >> tmp.constraints.txt
echo -e "# Eupercaria" >> tmp.constraints.txt
echo -e "lognormal(0,97.47,0.033)\tcrown\tT_rubr,P_fluv,G_acul,S_nigr,${nots}" >> tmp.constraints.txt
echo -e "# Perciformes" >> tmp.constraints.txt
echo -e "monophyletic\tNA\tP_fluv,G_acul,S_nigr,${nots}" >> tmp.constraints.txt
echo -e "# Notothenioidei" >> tmp.constraints.txt
echo -e "monophyletic\tNA\t${nots}" >> tmp.constraints.txt

# Generate xml files with beauti.rb.
for dataset_type in full strict permissive
do
    for model in HKY GTR
    do
        mkdir -p ../res/beast/${dataset_type}/${model}
        ruby beauti.rb -id ${dataset_type} -n ../res/alignments/${dataset_type} -o ../res/beast/${dataset_type}/${model}/xml -l 10000000 -c tmp.constraints.txt -m ${model} -g -bd -e -u -usd 0.5
        cat ../res/beast/${dataset_type}/${model}/xml/${dataset_type}.xml | sed "s/logEvery=\"5000\"/logEvery=\"50000\"/g" > ../res/beast/${dataset_type}/${model}/xml/${dataset_type}.xml.2
        mv -f ../res/beast/${dataset_type}/${model}/xml/${dataset_type}.xml.2 ../res/beast/${dataset_type}/${model}/xml/${dataset_type}.xml
    done
done

# Clean up.
rm -f tmp.constraints.txt

# Prepare directories for beast analyses.
for dataset_type in full strict permissive
do
    for model in HKY GTR
    do
        for n in {1..6}
        do
            rep_dir=../res/beast/${dataset_type}/${model}/replicates/r0${n}
            mkdir -p ${rep_dir}
            cp ../res/beast/${dataset_type}/${model}/xml/${dataset_type}.xml ${rep_dir}
            cat run_beast.slurm | sed "s/QQQQQQ/${dataset_type}/g" > ${rep_dir}/run_beast.slurm
            cat run_beast.sh | sed "s/QQQQQQ/${dataset_type}/g" > ${rep_dir}/run_beast.sh
        done
    done
done

# Start beast analyses from each replicate directory.
for dataset_type in full strict permissive
do
    for model in HKY GTR
    do
        for n in {1..6}
        do
            rep_dir=../res/beast/${dataset_type}/${model}/replicates/r0${n}
            cd ${rep_dir}
            if [ ! -f ${dataset_type}.log ]
            then
                slurm_available=`which squeue | wc -l | tr -d " "`
                if [[ ${slurm_available} == "1" ]]
                then
                    sbatch run_beast.slurm
                else
                    bash run_beast.sh
                fi
            fi
            cd - &> /dev/null
        done
    done
done
