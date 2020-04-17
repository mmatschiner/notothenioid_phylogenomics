# m_matschiner Tue Apr 14 20:27:04 CEST 2020

# This script needs the following dependencies.
# convert.py
# beauti.rb
# run_beast.slurm
# run_beast.sh

# Make the output directory.
mkdir -p ../res/alignments/05

# Load modules if necessary.
python_available=`which python | wc -l | tr -d " "`
if [[ ${python_available} == 1 ]]
then
    python_version=`python -c 'import sys; print(sys.version_info[0])'`
    if [[ ${python_version} != "3" ]]
    then
        module load Python/3.7.2-GCCcore-8.2.0
    fi
else
    module load Python/3.7.2-GCCcore-8.2.0
fi
ruby_available=`which ruby | wc -l | tr -d " "`
if [[ ${ruby_available} == 0 ]]
then
    module load Ruby/2.6.3-GCCcore-8.2.0
fi

# Make the constraints file.
tail -n +2 ../data/species.tab | cut -f 1 > tmp.species.txt
echo "                <distribution id=\"totalgroup.prior\" spec=\"beast.math.distributions.MRCAPrior\" tree=\"@tree.t:Species\" monophyletic=\"true\">" > tmp.constraints.xml
echo "                    <taxonset id=\"totalgroup\" spec=\"TaxonSet\">" >> tmp.constraints.xml
while read line
do
    echo "                          <taxon idref=\"${line}\"/>" >> tmp.constraints.xml
done < tmp.species.txt
echo "                    </taxonset>" >> tmp.constraints.xml
echo "                    <LogNormal name=\"distr\" meanInRealSpace=\"true\">" >> tmp.constraints.xml
echo "                        <parameter name=\"M\">100.0</parameter>" >> tmp.constraints.xml
echo "                        <parameter name=\"S\">0.1</parameter>" >> tmp.constraints.xml
echo "                    </LogNormal>" >> tmp.constraints.xml
echo "                </distribution>" >> tmp.constraints.xml
tail -n +2 ../data/species.tab | grep -v P_magn | cut -f 1 > tmp.species.txt
echo "                <distribution id=\"ingroup.prior\" spec=\"beast.math.distributions.MRCAPrior\" tree=\"@tree.t:Species\" monophyletic=\"true\">" >> tmp.constraints.xml
echo "                    <taxonset id=\"ingroup\" spec=\"TaxonSet\">" >> tmp.constraints.xml
while read line
do
    echo "                          <taxon idref=\"${line}\"/>" >> tmp.constraints.xml
done < tmp.species.txt
echo "                    </taxonset>" >> tmp.constraints.xml
echo "                </distribution>" >> tmp.constraints.xml
rm -f tmp.species.txt

# Generate XML input files for beast, for each alignment.
for fasta in ../res/alignments/04/*.fasta
do
    fasta_id=`basename ${fasta%_nucl.fasta}`
    mkdir -p ../res/alignments/05/${fasta_id}
    cat ${fasta} | cut -d "[" -f 1 > tmp.fasta
    python convert.py tmp.fasta ../res/alignments/05/${fasta_id}/${fasta_id}.nex -f nexus
    rm -f tmp.fasta
    if [ ! -f ../res/alignments/05/${fasta_id}/${fasta_id}.xml ]
    then
        ruby beauti.rb -id ${fasta_id} -n ../res/alignments/05/${fasta_id} -u -o ../res/alignments/05/${fasta_id} -c tmp.constraints.xml -l 25000000
    fi
    cat run_beast.slurm | sed "s/QQQQQQ/${fasta_id}/g" > ../res/alignments/05/${fasta_id}/run_beast.slurm
    cat run_beast.sh | sed "s/QQQQQQ/${fasta_id}/g" > ../res/alignments/05/${fasta_id}/run_beast.sh
done

# Clean up.
rm -f tmp.constraints.xml

# Go to each alignment directory and start beast analyses from there.
for xml in ../res/alignments/05/EOG*/EOG*.xml
do
    xml_id=`basename ${xml%.xml}`
    cd ../res/alignments/05/${xml_id}
    if [ ! -f ${xml_id}.log ]
    then
        slurm_available=`which squeue | wc -l | tr -d " "`
        if [[ ${slurm_available} == "1" ]]
        then
            sbatch run_beast.slurm
        else
            sbatch run_beast.sh
        fi
    fi
    cd - &> /dev/null
done
