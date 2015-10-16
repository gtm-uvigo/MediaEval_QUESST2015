#!/bin/bash

model=${1}
#Available models:
#CZtraps, HUtraps, RUtraps (BUT decoder)
#CZlstm, ENlstm, ESlstm, GAlstm (Kaldi decoder)
#CZdnn, ENdnn, ESdnn, GAdnn (Kaldi decoder)

if [ "${model}" == CZtraps ] || [ "${model}" == HUtraps ] || [ "${model}" == RUtraps ];then
./GetBUTPhonPost.sh ${model}
else
./GetKaldiPhonPost.sh ${model}
fi
