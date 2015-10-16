# MediaEval_QUESST2015
GTM-UVigo systems for Query-by-Example Search on Speech task at MediaEval 2015

Software requirements:
- [libarmadillo](http://arma.sourceforge.net)
- Matlab
- A recent version of [Kaldi toolkit](http://kaldi.sourceforge.net)
- Brno University of Technology phoneme recognizer based on long temporal context [PhnRec](http://speech.fit.vutbr.cz/software/phoneme-recognizer-based-long-temporal-context)

The scripts are organized in two folders:
- `PhonemePosteriorgrams`: scripts and models for extracting phoneme posteriorgrams.
- `SearchOnSpeech`: scripts for performing phoneme unit selection, subsequence dynamic time warping (S-DTW) and S-DTW with phoneme unit selection.
