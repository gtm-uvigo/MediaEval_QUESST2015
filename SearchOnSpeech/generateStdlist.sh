#!/bin/bash

#IMPORTANT!!! variable rootDir must be changed in order to locate the different files in your filesystem

DTWtype=${1}
parameterization=${2}
extension=${3}

rootDir=/DATADIR/QUESST2015/
listsDir=${rootDir}lists/
expDir=${rootDir}DTW${DTWtype}_${parameterization}/

tmpDir=/tmp/QUESST2015/
mkdir -p ${tmpDir}

cat ${expDir}DTWoutput/* > ${tmpDir}output

#A temporary file is generated for the scores of each query
while read query
do
cat ${tmpDir}output | grep " ${query} " | cut -d " " -f 1,5 | cut -d "_" -f 2  > ${tmpDir}${query}.out
done < ${listsDir}queriesTrain

#z-norm and stdlist generation
echo "generateStdlist('${tmpDir}','${expDir}dev.stdlist.xml','${listsDir}queriesTrain')" > execMatlab.m
matlab -nosplash -nojvm -nodesktop -r "execMatlab" &
wait
rm -rf execMatlab.m
