/*********************************************************************
 *  Copyright (C) Paula López Otero, GTM, Universidade de Vigo,2015  *
 *  E-mail: plopez@gts.uvigo.es                                      *
 * *******************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "DTWfunctions.h"
#include "FileFunctions.h"

#include <armadillo>
using namespace arma;

#define ARMA_USE_LAPACK
#define ARMA_USE_BLAS

int main(int argc,char **argv) {

  char experimentsFile[200],outputFile[200];

  strcpy(experimentsFile,argv[1]);
  strcpy(outputFile,argv[2]);

  int nExperiments = computeNumberOfExperiments(experimentsFile);
  Experiment *exps = (Experiment *)calloc(nExperiments,sizeof(Experiment));
  readExperimentsFile(experimentsFile,exps,nExperiments);

  int nPhonemes = exps[0].matchData.n_rows;

  Row<float> phonemeContributions = Row<float>(nPhonemes);

  phonemeContributions = computeRelevance(exps,nExperiments,nPhonemes)/nExperiments;

  Row<float> sortedContributions = sort(phonemeContributions);
  Row<uint> indices = sort_index(phonemeContributions);

  FILE *fOut = fopen(outputFile,"w");

  for(int i = 0; i < nPhonemes; i++) {
    fprintf(fOut,"%d %g\n",indices[i],phonemeContributions[indices[i]]);
  }
  fclose(fOut);

  free(exps);
  return(0);
}
