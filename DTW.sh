#!/bin/bash

#IMPORTANT!!! variable rootDir must be changed in order to locate the different files in your filesystem

DTWtype=${1}
parameterization=${2}
extension=${3}
documentsList=${4}
queriesList=${5}
outputFile=${6}
numberOfPhonemes=${7}

if [ "$DTWtype" == baseline ];then 
exeDTW=bin/S-DTW
elif [ "$DTWtype" == phonemeSelection ];then 
exeDTW=bin/S-DTW_phonemeSelection
else 
echo "Incorrect DTW type: baseline/phonemeSelection"
exit
fi

rootDir=/DATADIR/QUESST2015/

documentsDir=${rootDir}audio${parameterization}/
queriesDir=${rootDir}queries${parameterization}/

rm -rf ${outputFile}

if [ $DTWtype == "baseline" ];then
while read query
do
while read match
do
${exeDTW} ${documentsDir}${match}.${extension} ${queriesDir}${query}.${extension} ${match} ${query} >> ${outputFile}
done < ${documentsList}
done < ${queriesList}
elif [ "$DTWtype" == phonemeSelection ];then
phonemesFile=${rootDir}phonemeRelevance/phonemes/phonemes_${parameterization}_${numberOfPhonemes}
while read query
do
while read match
do
${exeDTW} ${documentsDir}${match}.${extension} ${queriesDir}${query}.${extension} ${match} ${query} ${phonemesFile} >> ${outputFile}
done < ${documentsList}
done < ${queriesList}
fi

