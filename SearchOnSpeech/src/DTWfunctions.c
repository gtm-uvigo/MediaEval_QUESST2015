/*********************************************************************
 *  Copyright (C) Paula López Otero, GTM, Universidade de Vigo,2015  *
 *  E-mail: plopez@gts.uvigo.es                                      *
 * *******************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <armadillo>
using namespace arma;

#define ARMA_USE_LAPACK
#define ARMA_USE_BLAS

float samplePeriod;
char matchName[200],queryName[200];

//Struct for storing the best alignment path
typedef struct Path
{
  int k;
  Col<int> px;
  Col<int> py;
} Path;

//Struct for storing the experiments required for the phoneme unit selection approach
typedef struct {

  char *match;
  char *query;
  int start;
  int duration;
  Mat<float> matchData;
  Mat<float> queryData;
} Experiment;

//Computation of the Pearson's correlation coefficient and transformation into cost
float pearson(Col<float> v1,Col<float> v2) {

  float accu1 = accu(v1);
  float accu2 = accu(v2);
  float result = (v1.n_rows*dot(v1,v2)-accu1*accu2)/sqrt((v1.n_rows*dot(v1,v1)-accu1*accu1)*(v2.n_rows*dot(v2,v2)-accu2*accu2));
  if(isnan(result)) {
    return(1);
  }
  else {
    return(1-(result+1)/2);
  }

}

//Computation of the contribution of each phoneme unit to Pearson's correlation coefficient
Row<float> pearsonDecomposed(Col<float> v1,Col<float> v2) {

  float accu1 = accu(v1);
  float accu2 = accu(v2);
  Row<float> result = Row<float>(v1.n_rows);

  for(unsigned int i = 0; i < v1.n_rows; i++) {
    result[i] = (v1.n_rows*v1[i]*v2[i]-(1/v1.n_rows)*accu1*accu2)/sqrt((v1.n_rows*dot(v1,v1)-accu1*accu1)*(v2.n_rows*dot(v2,v2)-accu2*accu2));
    if(isnan(result(i))) {
      result(i) = 0;
    }
  }

  return(result);
}

//Computation of the warping path
int path(Mat<float> costMatrix, int n, int m,int starty, Path *p)
{

  int i, j, k;
  
  i = n-1;
  j = starty;
  k = 1;
  
  Col<int> px = Col<int>(n*(starty+1));
  Col<int> py = Col<int>(n*(starty+1));

  px(0) = i;
  py(0) = j;
  
  while ((i > 0) || (j > 0)) {
    if (i == 0) {
      j--;
    }
    else if (j == 0) {
      i--;
    }
    else {
      Col<float> costs;
      costs << costMatrix(i-1,j) << costMatrix(i-1,j-1) << costMatrix(i,j-1) << endr;
      uword index;
      costs.min(index);
      
      switch(index) {
      case 0:
	i--;
	break;
      case 1:
	i--;
	j--;
	break;
      case 2:
	j--;
	break;
      }
    }
    
    px(k) = i;
    py(k) = j;
    k++;      
  }
  
  p->px = Col<int>(k);
  p->py = Col<int>(k);
  p->px = flipud(px.rows(0,k-1));
  p->py = flipud(py.rows(0,k-1));
  p->k = k;
  
  return 1;
}

//Computation of the cost matrix for DTW
void subsequence(Mat<float> queryData,Mat<float> matchData, int n, int m, Mat<float>& costMatrix)
{
  int i, j;

  costMatrix(0,0) = pearson(queryData.col(0),matchData.col(0));
  
  for (i=1; i<n; i++) {
    costMatrix(i,0) = pearson(queryData.col(i),matchData.col(0)) + costMatrix(i-1,0);
  }
  
  for (j=1; j<m; j++) {
    costMatrix(0,j) = pearson(queryData.col(0),matchData.col(j)); // subsequence variation: D(0,j) := c(x0, yj)
  }
  
  for (i=1; i<n; i++) {
    for (j=1; j<m; j++) {
      Col<float> costs = Col<float>(3);
      costs(0) = costMatrix(i-1,j);
      costs(1) = costMatrix(i-1,j-1);
      costs(2) = costMatrix(i,j-1);
      costMatrix(i,j) = pearson(queryData.col(i),matchData.col(j)) + costs.min();
    }
  }

}

//Computation of the best subsequence path
int subsequence_path(Mat<float> costMatrix, int n, int m, int starty, Path *p)
{
  int a_star;

  //First the warping path is computed
  if (!path(costMatrix, n, m,starty, p))
    return 0;
  
  //Then the start of the path is found
  uvec indices = find(p->px != 0);
  a_star = indices.min()-1;
  
  //Finally, the path is rebuilt
  p->px = p->px.rows(a_star,p->k-1);
  p->py = p->py.rows(a_star,p->k-1);
  p->k = p->k-a_star;

    return 1;
}

//Computation of all the matching candidates for queryData in matchData
void computeDTW(Mat<float> queryData,Mat<float> matchData,char *queryName,char *matchName,int samplePeriod) {

  Mat<float> costMatrix = Mat<float>(queryData.n_cols,matchData.n_cols);

  subsequence(queryData,matchData,queryData.n_cols,matchData.n_cols,costMatrix);

  int nCandidates = 100;

  Row<int> initCandidates = Row<int>(nCandidates);

  Row<float> lastRow = costMatrix.row(costMatrix.n_rows-1);  
  for(int i = 0; i < nCandidates; i++) {  
    
    uword index;
    float distance = lastRow.min(index);
    
    Path p;
    
    subsequence_path(costMatrix,queryData.n_cols,matchData.n_cols,index,&p);

    uvec search = find(initCandidates == p.py[0]);
    //If a new candidate is found, it is stored, otherwise it is ignored
    if(search.n_rows == 0) {
      printf("%s %s %g %g %g\n",matchName,queryName,(float)p.py(0)/100,(float)(index-p.py(0))/100,distance/(float)(index-p.py(0)+queryData.n_cols));
    }
    //A high cost is assigned to the found candidate in order to ignore it so as to find new candidates
    lastRow[index] = 1e20;
    initCandidates[i] = p.py(0);
  }

}

//Computation of the cost of each phoneme unit in the warping path obtained from aligning queryData and matchData
Row<float> computePhonemeCost(Mat<float> queryData,Mat<float> matchData) {

  Mat<float> costMatrix = Mat<float>(queryData.n_cols,matchData.n_cols);

  //First the cost matrix is computed and the best candidate is found
  subsequence(queryData,matchData,queryData.n_cols,matchData.n_cols,costMatrix);

  Row<float> lastRow = costMatrix.row(costMatrix.n_rows-1);  
  uword index;
  lastRow.min(index);
  
  Path p;
  
  subsequence_path(costMatrix,queryData.n_cols,matchData.n_cols,index,&p);
  
  //The cost of each phoneme unit is stored in phonemeCosts
  Row<float> phonemeCosts = Row<float>(queryData.n_rows);
  phonemeCorrelations.zeros();
  for(int i = 0; i < p.k; i++) {
    phonemeCosts  = phonemeCosts + (1-pearsonDecomposed(queryData.col(p.px[i]),matchData.col(p.py[i])))/2;
  }
  return(phonemeCosts/p.k);
}


//Computation of the relevance of each phoneme unit given a set of queries and their corresponding matching documents
Row<float> computeRelevance(Experiment *exps,int nExps,int nPhonemes) {
  
  int i;

  Row<float> result = Row<float>(nPhonemes);
  result.zeros();

   for(i = 0; i < nExps; i++) {
     result = result + computePhonemeCost(exps[i].queryData,exps[i].matchData);
  }
  
  return(result);
}
