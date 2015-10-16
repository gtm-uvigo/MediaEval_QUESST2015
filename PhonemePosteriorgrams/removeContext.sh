#!/bin/bash

#IMPORTANT!!! variable rootDir, dataDir and contextFile must be changed in order to locate the different files in your filesystem

#Folder where you want to write the output
rootDir=/DATADIR/QUESST2015/

#Folder where you have the wav files distributed for QUESST2015
dataDir=/DATADIR/QUESST2015/

WAVinDir=${dataDir}QUESST2015-dev/dev_queries/
WAVoutDir=${rootDir}dev_queries_noContext/
mkdir -p ${WAVoutDir}

#This variable points to the boundaries file included in QUESST2015 database
contextFile=${dataDir}QUESST2015-dev/boundaries_dev_queries.list

rm -rf ejecutaMatlab.m

files=$(ls ${WAVinDir}*.wav | cut -d "/" -f 8 | cut -d "." -f 1)

for ff in $files
do
start=$(cat ${contextFile} | grep ${ff} | cut -d " " -f 2)
end=$(cat ${contextFile} | grep ${ff} | cut -d " " -f 3)
duration=$(echo "$end - $start" | bc -l)
sox -t wav ${WAVinDir}${ff}.wav -t wav ${WAVoutDir}${ff}.wav trim ${start} ${duration}
done
