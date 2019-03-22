#!/usr/bin/env bash
# Author: Wenyi Tang
# Date: Mar. 18 2019
# Email: wenyitang@outlook.com

_DRN_TEST_MAT=${DRN_TEST_MAT}
_DRN_SAVE_DIR=${DRN_SAVE_DIR}
if [ ${DRN_TEST_MAT:0:1} != '/' ];then
  _DRN_TEST_MAT=`pwd`/${DRN_TEST_MAT}
fi
if [ ${DRN_SAVE_DIR:0:1} != '/' ];then
  _DRN_SAVE_DIR=`pwd`/${DRN_SAVE_DIR}
fi

if [ ! -e VideoSuperResolution ];
then
  git clone https://github.com/LoSealL/VideoSuperResolution -b ntire_2019
fi

pushd VideoSuperResolution 
if [ ! -e setup.py ];
then
  echo " [!] Can't find setup.py file! Make sure you are in the right place!"
fi

echo "DRN_TEST_MAT=${_DRN_TEST_MAT}"
echo "DRN_SAVE_DIR=${_DRN_SAVE_DIR}"

pip install -q -e .
python prepare_data.py --filter=drn -q
echo " [*] Model extracted into Results/drn/save"
python VSR/Tools/DataProcessing/NTIRE19Denoise.py --validation=${_DRN_TEST_MAT} --save_dir=${_DRN_SAVE_DIR}/1/
pushd VSRTorch
python eval.py drn --cuda --ensemble -t=${_DRN_SAVE_DIR}/1/ --output_index=0
popd
python VSR/Tools/DataProcessing/NTIRE19Denoise.py --results=Results/drn/1/ --save_dir=${_DRN_SAVE_DIR}/2/
echo " [*] Processing done. Results are in ${_DRN_SAVE_DIR}/2/results.mat"
echo "     PNG files are saved in VideoSuperResolution/Results/drn/1/"
popd
