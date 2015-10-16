This folder includes scripts for performing subsequence dynamic time warping (S-DTW) for query-by-example spoken document retrieval as well as phoneme unit selection [2] in the context of Query-by-example Search on Speech Task at MediaEval 2015. These scripts assume that you have already extracted the phoneme posteriorgrams following the scripts in the folder `PhonemePosteriorgrams`.

- Performing S-DTW using the phoneme posteriorgrams ESlstm:

  `exeDTW.sh baseline ESlstm fea`

- Performing phoneme unit selection of phoneme posteriorgrams ESlstm:

  `RelevantPhonemes.sh ESlstm fea`
  
- Performing S-DTW with phoneme unit selection using the phoneme posteriorgrams ESlstm including only the 20 most relevant phonemes:
 
  `exeDTW.sh phonemeSelection ESlstm fea 20`

Tips:
- These scripts rely on a predetermined folder structure, so please have a look at the scripts before running them in order to allow them to find the required files in your filesystem.
- The script `exeDTW.sh` requires two lists, audioTrain and queriesTrain, that include the name of the documents and the queries (see files in `sampleLists`).


[1] P. López Otero, L. Docío Fernández, C. García Mateo, "GTM-UVigo Systems for the Query-by-Example Search on Speech Task at MediaEval 2015", Proceedings of the MediaEval 2015 Workshop, 2015.

[2] P. López Otero, L. Docío Fernández, C. García Mateo, "Phonetic Unit Selection for Cross-Lingual Query-by-Example Spoken Term Detection", Proceedings of IEEE Automatic Speech Recognition and Understanding Workshop, 2015.


