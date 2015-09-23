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

  char matchFile[200],queryFile[200];
  float samplePeriod;
  char matchName[200],queryName[200];

  strcpy(matchFile,argv[1]);
  strcpy(queryFile,argv[2]);
  strcpy(matchName,argv[3]);
  strcpy(queryName,argv[4]);

  samplePeriod = getSamplePeriod(matchFile)*10e-8;

  Mat<float> matchData = readFile(matchFile);
  Mat<float> queryData = readFile(queryFile);

  computeDTW(queryData,matchData,queryName,matchName,samplePeriod);
}
