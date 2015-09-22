#!/bin/bash

#IMPORTANT!!! variables rootDir and RTTM must be changed in order to locate the different files in your filesystem

#Usage: parameterization extension
#When using our phoneme posteriorgrams, the following options can be run:
#ESlstm fea
#ESdnn fea
#GAlstm fea
#GAdnn fea
#CZlstm fea
#CZdnn fea
#ENlstm fea
#ENdnn fea
#CZtraps post
#HUtraps post
#RUtraps post

parameterization=${1}
extension=${2}

rootDir=/DATADIR/QUESST2015/
documentsDir=${rootDir}audio${parameterization}/
queriesDir=${rootDir}queries${parameterization}/
RTTM=/DATADIR/QUESST2015/QUESST2015-dev/quesst2015_dev.rttm
outputDir=${rootDir}phonemeRelevance/phonemes/
mkdir -p ${outputDir}

tmpDir=/tmp/QUESST2015/
mkdir -p ${tmpDir}

exeRelevantPhonemes=bin/phonemeRelevance

#First, a file with the experiments that will be used to sort the phoneme units by relevance is created
cat ${RTTM} | sed 's/  */ /g' | grep "quesst2015_dev_" | cut -d " " -f 2,4,5,6 > ${tmpDir}rttm

rm -rf ${tmpDir}experiments_${parameterization}

while read line
do
match=$(echo $line | cut -d " " -f 1)
query=$(echo $line | cut -d " " -f 4)
start=$(echo $line | cut -d " " -f 2)
duration=$(echo $line | cut -d " " -f 3)
echo "${documentsDir}${match}.${extension} ${queriesDir}${query}.${extension} ${start} ${duration}" >> ${tmpDir}experiments_${parameterization}
done < ${tmpDir}rttm

#Computation of the relevance of the phoneme units. Usage:
#bin/phonemeRelevance experimentsFile output
#The format of the output is "numberOfPhonemeUnit relevanceFactor"
${exeRelevantPhonemes} ${tmpDir}experiments_${parameterization} ${outputDir}relevantPhonemes_${parameterization}

#As there is no criterion to decide how many phoneme units are relevant, we just take 10, 20, 30, 40, 50...
if [ "${parameterization}" == "PostESlstm" ] || [ "${parameterization}" == "PostESdbn" ] || [ "${parameterization}" == "PostGAlstm" ] || [ "${parameterization}" == "PostGAdbn" ];then
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,10p | sort -n > ${outputDir}phonemes_${parameterization}_10
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,20p | sort -n > ${outputDir}phonemes_${parameterization}_20
elif [ "${parameterization}" == "PostCZlstm" ] || [ "${parameterization}" == "PostCZdbn" ];then
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,10p | sort -n > ${outputDir}phonemes_${parameterization}_10
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,20p | sort -n > ${outputDir}phonemes_${parameterization}_20
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,30p | sort -n > ${outputDir}phonemes_${parameterization}_30
elif [ "${parameterization}" == "CZtraps" ] || [ "${parameterization}" == "RUtraps" ];then
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,10p | sort -n > ${outputDir}phonemes_${parameterization}_10
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,20p | sort -n > ${outputDir}phonemes_${parameterization}_20
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,30p | sort -n > ${outputDir}phonemes_${parameterization}_30
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,40p | sort -n > ${outputDir}phonemes_${parameterization}_40
elif [ "${parameterization}" == "HUsoftening" ];then
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,10p | sort -n > ${outputDir}phonemes_${parameterization}_10
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,20p | sort -n > ${outputDir}phonemes_${parameterization}_20
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,30p | sort -n > ${outputDir}phonemes_${parameterization}_30
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,40p | sort -n > ${outputDir}phonemes_${parameterization}_40
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,50p | sort -n > ${outputDir}phonemes_${parameterization}_50
elif [ "${parameterization}" == "PostENlstm" ] || [ "${parameterization}" == "PostENdbn" ];then
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,10p | sort -n > ${outputDir}phonemes_${parameterization}_10
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,20p | sort -n > ${outputDir}phonemes_${parameterization}_20
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,30p | sort -n > ${outputDir}phonemes_${parameterization}_30
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,40p | sort -n > ${outputDir}phonemes_${parameterization}_40
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,50p | sort -n > ${outputDir}phonemes_${parameterization}_50
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,60p | sort -n > ${outputDir}phonemes_${parameterization}_60
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,70p | sort -n > ${outputDir}phonemes_${parameterization}_70
cat ${outputDir}relevantPhonemes_${parameterization} | cut -d " " -f 1 | sed -n 1,80p | sort -n > ${outputDir}phonemes_${parameterization}_80
fi
