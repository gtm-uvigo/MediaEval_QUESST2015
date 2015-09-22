CFLAGS = -g -Wall
CC = gcc
CXX = g++
SRC_DTW = src/DTWfunctions.c
SRC_FILE = src/FileFunctions.c
OBJ_DTW = src/DTWfunctions.o
OBJ_FILE = src/FileFunctions.o
SRC_SDTW_SEL = src/S-DTW_phonemeSelection.c
EXEC_SDTW_SEL = bin/S-DTW_phonemeSelection
SRC_PHON = src/phonemeRelevance.c
EXEC_PHON = bin/phonemeRelevance
SRC_SDTW = src/S-DTW.c
EXEC_SDTW = bin/S-DTW
LIBS = -lm -llapack -lblas -larmadillo

all:

	$(CXX) $(CFLAGS) -c $(SRC_DTW) -o $(OBJ_DTW)
	$(CXX) $(CFLAGS) -c $(SRC_FILE) -o $(OBJ_FILE)
	$(CXX) $(CFLAGS) $(SRC_SDTW_SEL) $(OBJ_DTW) $(OBJ_FILE) -o $(EXEC_SDTW_SEL) $(LIBS)
	$(CXX) $(CFLAGS) $(SRC_SDTW) $(OBJ_DTW) $(OBJ_FILE) -o $(EXEC_SDTW) $(LIBS)
	$(CXX) $(CFLAGS) $(SRC_PHON) $(OBJ_DTW) $(OBJ_FILE) -o $(EXEC_PHON) $(LIBS)

clean:
	-rm -f *~ *.o
