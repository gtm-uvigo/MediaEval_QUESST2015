#!/bin/bash

#IMPORTANT!!! variables rootDir, dataDir and KALDI_ROOT must be changed in order to locate the different files in your filesystem

export KALDI_ROOT=/software/KALDI/kaldi-trunk
export PATH=$KALDI_ROOT/egs/wsj/s5/utils/:$KALDI_ROOT/egs/wsj/s5/steps/:$KALDI_ROOT/tools/sph2pipe_v2.5/:$KALDI_ROOT/tools/srilm/:$KALDI_ROOT/tools/srilm/bin/i686-m64/:$KALDI_ROOT/src/bin:$KALDI_ROOT/tools/openfst/bin:$KALDI_ROOT/src/fstbin/:$KALDI_ROOT/src/gmmbin/:$KALDI_ROOT/src/featbin/:$KALDI_ROOT/src/lm/:$KALDI_ROOT/src/sgmmbin/:$KALDI_ROOT/src/sgmm2bin/:$KALDI_ROOT/src/fgmmbin/:$KALDI_ROOT/src/latbin/:$KALDI_ROOT/src/nnetbin:$KALDI_ROOT/src/nnet2bin/:$KALDI_ROOT/src/kwsbin:$PWD/kaldiScripts/utils/:$PWD/kaldiScripts/steps/:$PWD/kaldiScripts/:$PWD:$PATH:./kaldiScripts/utils:./kaldiScripts/steps
export LC_ALL=C


# IMPORTANT:
ln -s kaldiScripts/utils utils
ln -s kaldiScripts/steps steps

# Set this to whereVER you want to write the posteriorgrams
rootDir=/DATADIR/QUESST2015/

# Set this to wherever you have QUESST2015 database
dataDir=/DATADIR/QUESST2015/

# Set this to wherever you have your Documents (wav files). We assume you are using the original audio documents
documentsDir=${dataDir}QUESST2015/QUESST2015-dev/Audio
# Set this to wherever you have your Queries (wav files). We assume you are using the queries obtained by executing removeContext.sh
queriesDir=${rootDir}QUESST2015/dev_queries_noContext
# Set this wherever you have your acoustic models trained with KALDI
modelsDir=./kaldiModels

#Acoustic Models: ESdnn, ESlstm, ...
PHONMODEL=$1

AMODELS=${modelsDir}/${PHONMODEL}

tmpDir=./tmp/
mkdir -p ${rootDir}audio${PHONMODEL} 
mkdir -p ${tmpDir}${PHONMODEL}/data


[ -f ./path.sh ] && . ./path.sh; # source the path.
[ -f ./cmd.sh ] && . ./cmd.sh; # source train and decode cmds.
. kaldiScripts/utils/parse_options.sh

nj=1

###################  DOCUMENTS PROCESSING  ##############################

ls $documentsDir/ | xargs -I% basename % .wav | awk -v path=$documentsDir '{printf "%s %s/%s.wav\n", $0,path,$0}' > ${tmpDir}${PHONMODEL}/data/wav.scp
awk '{ print $1, $1}'  ${tmpDir}${PHONMODEL}/data/wav.scp > ${tmpDir}${PHONMODEL}/data/utt2spk
kaldiScripts/utils/utt2spk_to_spk2utt.pl ${tmpDir}${PHONMODEL}/data/utt2spk > ${tmpDir}${PHONMODEL}/data/spk2utt

dataset_dir=${tmpDir}${PHONMODEL}/data
mfccdir=mfcc
dataset=audio

if [[ $PHONMODEL =~ dnn ]] ; then
  beam=16
  latticebeam=10
  decode_extra_opts=( --num-threads 1 )

  kaldiScripts/steps/make_mfcc.sh --cmd "$train_cmd" --nj $nj --mfcc-config conf/mfcc_8Khz.conf ${dataset_dir} ${tmpDir}${PHONMODEL}/make_mfcc/${dataset} $mfccdir
  kaldiScripts/steps/compute_cmvn_stats.sh ${dataset_dir} ${tmpDir}${PHONMODEL}/make_mfcc/${dataset} $mfccdir

  decode_dir=${AMODELS}/tri4b/decode_${dataset}
  graph=${AMODELS}/tri4b/graph
  kaldiScripts/steps/decode_fmllr.sh --skip-scoring true --beam $beam --lattice-beam $latticebeam --nj $nj --cmd "$decode_cmd" \
    "${decode_extra_opts[@]}" $graph ${dataset_dir} ${decode_dir}


  gmmdir=${AMODELS}/tri4b
  data_fmllr=${tmpDir}${PHONMODEL}/data-fmllr-tri4b
  . kaldiScripts/utils/parse_options.sh 

  # Store fMLLR features, so we can train on them easily,
  dir=$data_fmllr/${dataset}
  kaldiScripts/steps/nnet/make_fmllr_feats.sh --nj $nj --cmd "$train_cmd" \
     --transform-dir $gmmdir/decode_${dataset} \
     $dir ${dataset_dir} $gmmdir $dir/log $dir/data 

  modeldir=${AMODELS}/dnn_pretrain-dbn_dnn_smbr_i1lats
  kaldiScripts/getPosteriorgramsNNetKaldi.sh --nj $nj  --cmd "$decode_cmd" --config conf/decode_dnn.config \
     --nnet $modeldir/final.nnet $data_fmllr/${dataset} $modeldir/decode_${dataset}

  for st in $(eval echo {1..$nj})
  do
    copy-feats-to-sphinx --output-dir=${tmpDir}${PHONMODEL}/posteriorgrams --output-ext=fea ark:$modeldir/decode_${dataset}/dnnoutput.${st}.nnet
  done

  echo "postprocessKaldiPosteriograms('${AMODELS}/dnn_pretrain-dbn_dnn_smbr_i1lats/dnn_infopdfs.txt','${AMODELS}/dnn_pretrain-dbn_dnn_smbr_i1lats/phones.txt','${tmpDir}${PHONMODEL}/posteriorgrams/','${rootDir}audio${PHONMODEL}/')" > exec_postprocessKaldiPosteriograms.m
  echo "quit;" >> exec_postprocessKaldiPosteriograms.m
  matlab -nosplash -nojvm -nodesktop -r "exec_postprocessKaldiPosteriograms" &
  wait

  rm -rf exec_postprocessKaldiPosteriograms.m
#  rm -rf ${tmpDir}${PHONMODEL}/posteriorgrams ${tmpDir}${PHONMODEL}/make_mfcc $data_fmllr $mfccdir $modeldir/decode_${dataset} ${AMODELS}/tri4b/decode_${dataset}


elif [[ $PHONMODEL =~ lstm ]] ; then

  datadir=${tmpDir}${PHONMODEL}/data-fbank40

  # Make the FBANK features
  kaldiScripts/utils/copy_data_dir.sh ${dataset_dir} $datadir || exit 1; rm $datadir/{cmvn,feats}.scp
  kaldiScripts/steps/make_fbank_pitch.sh --nj $nj --cmd "$train_cmd" --fbank-config conf/fbank.conf --pitch-config conf/pitch.conf \
    $datadir $datadir/log $datadir/data 
  kaldiScripts/steps/compute_cmvn_stats.sh $datadir $datadir/log $datadir/data 

  modeldir=${AMODELS}/lstm
  ./kaldiScripts/getPosteriorgramsNNetKaldi.sh --nj $nj --cmd "$decode_cmd" --config conf/decode_dnn.config \
      $datadir $modeldir/decode_${dataset} 

  for st in $(eval echo {1..$nj})
  do
    copy-feats-to-sphinx --output-dir=${tmpDir}${PHONMODEL}/posteriorgrams --output-ext=fea ark:$modeldir/decode_${dataset}/dnnoutput.${st}.nnet
  done

  echo "postprocessKaldiPosteriograms('${AMODELS}/lstm/lstm_infopdfs.txt','${AMODELS}/lstm/phones.txt','${tmpDir}${PHONMODEL}/posteriorgrams/','${rootDir}audio${PHONMODEL}/')" > exec_postprocessKaldiPosteriograms.m
  echo "quit;" >> exec_postprocessKaldiPosteriograms.m
  matlab -nosplash -nojvm -nodesktop -r "exec_postprocessKaldiPosteriograms" &
  wait
 
  rm -rf exec_postprocessKaldiPosteriograms.m
#  rm -rf ${tmpDir}${PHONMODEL}/posteriorgrams $modeldir/decode_${dataset} ${tmpDir}${PHONMODEL}/data-fbank40


else
  echo "Only LSTM or DNN models"
fi

###################  QUERIES PROCESSING  ##############################

rm -rf ${tmpDir}${PHONMODEL}/

mkdir -p ${rootDir}queries${PHONMODEL} 
mkdir -p ${tmpDir}${PHONMODEL}/data


ls $queriesDir/ | xargs -I% basename % .wav | awk -v path=$queriesDir '{printf "%s %s/%s.wav\n", $0,path,$0}' > ${tmpDir}${PHONMODEL}/data/wav.scp
awk '{ print $1, $1}'  ${tmpDir}${PHONMODEL}/data/wav.scp > ${tmpDir}${PHONMODEL}/data/utt2spk
kaldiScripts/utils/utt2spk_to_spk2utt.pl ${tmpDir}${PHONMODEL}/data/utt2spk > ${tmpDir}${PHONMODEL}/data/spk2utt

dataset_dir=${tmpDir}${PHONMODEL}/data
mfccdir=mfcc
dataset=queries

if [[ $PHONMODEL =~ dnn ]] ; then
  beam=16
  latticebeam=10
  decode_extra_opts=( --num-threads 1 )

  kaldiScripts/steps/make_mfcc.sh --cmd "$train_cmd" --nj $nj --mfcc-config conf/mfcc_8Khz.conf ${dataset_dir} ${tmpDir}${PHONMODEL}/make_mfcc/${dataset} $mfccdir
  kaldiScripts/steps/compute_cmvn_stats.sh ${dataset_dir} ${tmpDir}${PHONMODEL}/make_mfcc/${dataset} $mfccdir

  decode_dir=${AMODELS}/tri4b/decode_${dataset}
  graph=${AMODELS}/tri4b/graph
  kaldiScripts/steps/decode_fmllr.sh --skip-scoring true --beam $beam --lattice-beam $latticebeam --nj $nj --cmd "$decode_cmd" \
    "${decode_extra_opts[@]}" $graph ${dataset_dir} ${decode_dir}


  gmmdir=${AMODELS}/tri4b
  data_fmllr=${tmpDir}${PHONMODEL}/data-fmllr-tri4b
  . kaldiScripts/utils/parse_options.sh 

  # Store fMLLR features, so we can train on them easily,
  dir=$data_fmllr/${dataset}
  kaldiScripts/steps/nnet/make_fmllr_feats.sh --nj $nj --cmd "$train_cmd" \
     --transform-dir $gmmdir/decode_${dataset} \
     $dir ${dataset_dir} $gmmdir $dir/log $dir/data 

  modeldir=${AMODELS}/dnn_pretrain-dbn_dnn_smbr_i1lats
  ./kaldiScripts/getPosteriorgramsNNetKaldi.sh --nj $nj  --cmd "$decode_cmd" --config conf/decode_dnn.config \
     --nnet $modeldir/final.nnet $data_fmllr/${dataset} $modeldir/decode_${dataset}

  for st in $(eval echo {1..$nj})
  do
    copy-feats-to-sphinx --output-dir=${tmpDir}${PHONMODEL}/posteriorgrams --output-ext=fea ark:$modeldir/decode_${dataset}/dnnoutput.${st}.nnet
  done

  echo "postprocessKaldiPosteriograms('${AMODELS}/dnn_pretrain-dbn_dnn_smbr_i1lats/dnn_infopdfs.txt','${AMODELS}/dnn_pretrain-dbn_dnn_smbr_i1lats/phones.txt','${tmpDir}${PHONMODEL}/posteriorgrams/','${rootDir}queries${PHONMODEL}/')" > exec_postprocessKaldiPosteriograms.m
  echo "quit;" >> exec_postprocessKaldiPosteriograms.m
  matlab -nosplash -nojvm -nodesktop -nodisplay -r "exec_postprocessKaldiPosteriograms" &
  wait

  rm -rf exec_postprocessKaldiPosteriograms.m
  rm -rf ${tmpDir}${PHONMODEL}/posteriorgrams ${tmpDir}${PHONMODEL}/make_mfcc $data_fmllr $mfccdir $modeldir/decode_${dataset} ${AMODELS}/tri4b/decode_${dataset}


elif [[ $PHONMODEL =~ lstm ]] ; then

  datadir=${tmpDir}${PHONMODEL}/data-fbank40

  # Make the FBANK features
  kaldiScripts/utils/copy_data_dir.sh ${dataset_dir} $datadir || exit 1; rm $datadir/{cmvn,feats}.scp
  kaldiScripts/steps/make_fbank_pitch.sh --nj $nj --cmd "$train_cmd" --fbank-config conf/fbank.conf --pitch-config conf/pitch.conf \
    $datadir $datadir/log $datadir/data 
  kaldiScripts/steps/compute_cmvn_stats.sh $datadir $datadir/log $datadir/data 

  modeldir=${AMODELS}/lstm
  ./kaldiScripts/getPosteriorgramsNNetKaldi.sh --nj $nj --cmd "$decode_cmd" --config conf/decode_dnn.config \
      $datadir $modeldir/decode_${dataset} 

  for st in $(eval echo {1..$nj})
  do
    copy-feats-to-sphinx --output-dir=${tmpDir}${PHONMODEL}/posteriorgrams --output-ext=fea ark:$modeldir/decode_${dataset}/dnnoutput.${st}.nnet
  done

  echo "postprocessKaldiPosteriograms('${AMODELS}/lstm/lstm_infopdfs.txt','${AMODELS}/lstm/phones.txt','${tmpDir}${PHONMODEL}/posteriorgrams/','${rootDir}queries${PHONMODEL}/')" > exec_postprocessKaldiPosteriograms.m
  echo "quit;" >> exec_postprocessKaldiPosteriograms.m
  matlab -nosplash -nojvm -nodesktop -nodisplay -r "exec_postprocessKaldiPosteriograms" &
  wait
 
  rm -rf exec_postprocessKaldiPosteriograms.m
  rm -rf ${tmpDir}${PHONMODEL}/posteriorgrams $modeldir/decode_${dataset} ${tmpDir}${PHONMODEL}/data-fbank40


else
  echo "Only LSTM or DNN models"
fi

rm -rf ./tmp utils steps
