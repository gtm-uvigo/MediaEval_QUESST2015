#!/bin/bash

#IMPORTANT!!! variables rootDir, dataDir and PHNRECBIN must be changed in order to locate the different files in your filesystem

# BUT PhnRec binary programs
PHNRECBIN=/software/PhnRec/
export LD_LIBRARY_PATH=${PHNRECBIN}

#Acoustic Models: CZtraps, HUtraps, RUtraps
PHONMODEL=${1}

#phoneme recognizer: PHN_CZ_SPDAT_LCRC_N1500, PHN_HU_SPDAT_LCRC_N1500, PHN_RU_SPDAT_LCRC_N1500
case $PHONMODEL in
CZtraps)
  PHNREC=PHN_CZ_SPDAT_LCRC_N1500
  ;;
HUtraps)
  PHNREC=PHN_HU_SPDAT_LCRC_N1500
  ;;
RUtraps)
  PHNREC=PHN_RU_SPDAT_LCRC_N1500
  ;;
*)
  echo $"Usage: $0 {CZtraps|HUtraps|RUtraps}"
  exit 1
esac

echo $PHNREC

#phoneme recognizer: PHN_CZ_SPDAT_LCRC_N1500, PHN_HU_SPDAT_LCRC_N1500, PHN_RU_SPDAT_LCRC_N1500

#Set this to wherever you want to write the output
rootDir=/DATADIR/QUESST2015/

#This variable points to the Audio directory included in QUESST2015 database
documentsDir=/DATADIR/QUESST2015/QUESST2015-dev/Audio
#This variable points to the queries without context extracted using removeContext.sh
queriesDir=${rootDir}dev_queries_noContext

tmpDir=./tmp/QUESST2015/
mkdir -p ${rootDir}audio${PHONMODEL} 
mkdir -p ${tmpDir}${PHONMODEL}/htkout ${tmpDir}${PHONMODEL}/audiotmp

FILES=(${documentsDir}/*wav)
for f in "${FILES[@]}"; do
	fname=`basename $f .wav`
	sox "$f" -r 8000 -c 1 -t raw ${tmpDir}${PHONMODEL}/audiotmp/${fname}.raw
	echo "${tmpDir}${PHONMODEL}/audiotmp/${fname}.raw ${tmpDir}${PHONMODEL}/htkout/${fname}.lop" > ${tmpDir}${PHONMODEL}/list.post
	echo "${tmpDir}${PHONMODEL}/htkout/${fname}.lop" > ${tmpDir}${PHONMODEL}/list.scp

	echo "Posterior generation .... "
	$PHNRECBIN/phnrec -t post -c $PHNRECBIN/$PHNREC -l ${tmpDir}${PHONMODEL}/list.post

done

echo "postprocessBUTPosteriograms('${tmpDir}${PHONMODEL}/htkout/','${rootDir}audio${PHONMODEL}/')" > exec_postprocessBUTPosteriograms.m
matlab -nosplash -nojvm -nodesktop -r "exec_postprocessBUTPosteriograms" &
wait


rm -rf exec_postprocessBUTPosteriograms.m
rm -rf ${tmpDir}${PHONMODEL}/audiotmp ${tmpDir}${PHONMODEL}/htkout ${tmpDir}${PHONMODEL}/list.post ${tmpDir}${PHONMODEL}/list.scp


mkdir -p ${rootDir}queries${PHONMODEL} 
mkdir -p ${tmpDir}${PHONMODEL}/htkout ${tmpDir}${PHONMODEL}/audiotmp

FILES=(${queriesDir}/*wav)
for f in "${FILES[@]}"; do
	fname=`basename $f .wav`
	sox "$f" -r 8000 -c 1 -t raw ${tmpDir}${PHONMODEL}/audiotmp/${fname}.raw
	echo "${tmpDir}${PHONMODEL}/audiotmp/${fname}.raw ${tmpDir}${PHONMODEL}/htkout/${fname}.lop" > ${tmpDir}${PHONMODEL}/list.post
	echo "${tmpDir}${PHONMODEL}/htkout/${fname}.lop" > ${tmpDir}${PHONMODEL}/list.scp

	echo "Posterior generation .... "
	$PHNRECBIN/phnrec -t post -c $PHNRECBIN/$PHNREC -l ${tmpDir}${PHONMODEL}/list.post

done

echo "postprocessBUTPosteriograms('${tmpDir}${PHONMODEL}/htkout/','${rootDir}queries${PHONMODEL}/')" > exec_postprocessBUTPosteriograms.m
matlab -nosplash -nojvm -nodesktop -r "exec_postprocessBUTPosteriograms" &
wait

rm -rf exec_postprocessBUTPosteriograms.m
rm -rf ${tmpDir}${PHONMODEL}/audiotmp ${tmpDir}${PHONMODEL}/htkout ${tmpDir}${PHONMODEL}/list.post ${tmpDir}${PHONMODEL}/list.scp
rm -rf ${tmpDir}${PHONMODEL}

