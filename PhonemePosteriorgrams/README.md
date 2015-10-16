This folder includes scripts for extracting phoneme posteriorgrams as described in [1] in the context of Query-by-example Search on Speech Task at MediaEval 2015.

- First of all, you have to remove the context of the queries, as it will not be used in these experiments:

  `removeContext.sh`

- To extract posteriorgrams:

  `GetPhonemePosteriorgrams.sh modelName`

  The available models are:
  - CZtraps, HUtraps, RUtraps (BUT decoder)
  - CZlstm, ENlstm, ESlstm, GAlstm (Kaldi decoder)
  - CZdnn, ENdnn, ESdnn, GAdnn (Kaldi decoder)

  These models can be downloaded at (http://gtm.uvigo.es/KaldiModelsQUESST2015.php).
  
Tips:
- These scripts rely on a predetermined folder structure, so please have a look at the scripts before running them in order to allow them to find the required files in your filesystem.

[1] P. López Otero, L. Docío Fernández, C. García Mateo, "GTM-UVigo Systems for the Query-by-Example Search on Speech Task at MediaEval 2015", Proceedings of the MediaEval 2015 Workshop, 2015.
