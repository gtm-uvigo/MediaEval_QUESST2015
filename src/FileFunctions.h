Col<int> readKeepFile(char *dataFile);
int getSamplePeriod(char *dataFile);
Mat<float> readFile(char *dataFile);
int computeNumberOfExperiments(char *experimentsFile);
void readExperimentsFile(char *experimentsFile,Experiment* exps,int nExperiments);
