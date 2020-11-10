# m_matschiner Wed Apr 15 00:22:32 CEST 2020

# If java is not available try loading it as a module.
java_available=`which java | wc -l | tr -d " "`
if [[ ${java_available} == 0 ]]
then
    module load Java/11.0.2
fi

# Download and install beast.
if [ ! -f beast/bin/beast ]
then
	wget https://github.com/CompEvol/beast2/releases/download/v2.6.2/BEAST.v2.6.2.Linux.tgz
	tar -xzf BEAST.v2.6.2.Linux.tgz
	rm -f BEAST.v2.6.2.Linux.tgz
fi

# Make sure the bModelTest package is installed.
bmt_installed=`beast/bin/packagemanager -list | grep bModelTest | cut -d "|" -f 2 | tr -d " "`
if [[ ${bmt_installed} == "NA" ]]
then
	beast/bin/packagemanager -add bModelTest
fi

## Run or resume beast analysis.
if [ ! -f EOG090C0A7L.log ]
then
    beast/bin/beast -seed ${RANDOM} EOG090C0A7L.xml
else
    beast/bin/beast -seed ${RANDOM} -resume EOG090C0A7L.xml
fi
