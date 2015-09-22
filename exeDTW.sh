#!/bin/bash

#IMPORTANT!!! variable rootDir must be changed in order to locate the different files in your filesystem

#This script performs S-DTW and generates dev.stdlist.xml as output
#DTWtype can be baseline (for regular S-DTW) or phonemeSelection (for S-DTW featuring phoneme selection)
#When using our phoneme posteriorgrams, parameterization and extension can have the following values:
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
#When using phonemeSelection mode, numberOfPhonemes must be specified. Possible values are 10, 20, 30, 40, 50, 60, 70, 80, but not for all parameterizations. See RelevantPhonemes.sh for details


DTWtype=${1}
parameterization=${2}
extension=${3}
numberOfPhonemes=${4}

rootDir=/DATADIR/QUESST2015/
#It is assumed that there is a lists folder in your rootDir including two lists: audioTrain and queriesTrain. See the sample lists for more details
listsDir=${rootDir}lists/
#Folder in which the output is written
expDir=${rootDir}DTW${DTWtype}_${parameterization}/
mkdir -p ${expDir}
mkdir -p ${expDir}DTWoutput

#First we compute S-DTW
./DTW.sh ${DTWtype} ${parameterization} ${extension} ${listsDir}audioTrain ${listsDir}queriesTrain ${expDir}DTWoutput/output ${numberOfPhonemes}

#After that, we apply z-norm and generate the output file
./generateStdlist.sh ${DTWtype} ${parameterization} ${extension}
