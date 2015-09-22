#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <armadillo>
using namespace arma;

#define ARMA_USE_LAPACK
#define ARMA_USE_BLAS

typedef struct {

  char *match;
  char *query;
  int start;
  int duration;
  Mat<float> matchData;
  Mat<float> queryData;
} Experiment;

void computeDTW(Mat<float> queryData,Mat<float> matchData,char *queryName,char *matchName,int samplePeriod);
Row<float> computeRelevance(Experiment *exps,int nExps,int nPhonemes);
