#!/usr/bin/env bash
# Author: Wenyi Tang
# Date: Mar. 18 2019
# Email: wenyitang@outlook.com

#DRN_TEST_MAT=
#DRN_SAVE_DIR=
if [ ${DRN_SAVE_DIR:0:1} == '/' ];
then
  _ABS=1
else
  _ABS=0
fi

if [ ! -e VideoSuperResolution ];
then
  git clone https://github.com/LoSealL/VideoSuperResolution -b ntire_2019
fi

pushd VideoSuperResolution
if [ ${_ABS} == 0 ];
then
  DRN_SAVE_DIR=../${DRN_SAVE_DIR}
  DRN_TEST_MAT=../${DRN_TEST_MAT}
fi
if 
if [ ! -e setup.py ];
then
  echo " [!] Can't find setup.py file! Make sure you are in the right place!"
fi

echo "DRN_TEST_MAT=${DRN_TEST_MAT}"
echo "DRN_SAVE_DIR=${DRN_SAVE_DIR}"

pip install -q -e .
python prepare_data.py --filter=drn -q
echo " [*] Model extracted into Results/drn/save"
python VSR/Tools/DataProcessing/NTIRE19Denoise.py --validation=${DRN_TEST_MAT} --save_dir=${DRN_SAVE_DIR}/1/
pushd VSRTorch
if [ ${_ABS} == 0 ];
then
  DRN_SAVE_DIR=../${DRN_SAVE_DIR}
  DRN_TEST_MAT=../${DRN_TEST_MAT}
  echo "DRN_SAVE_DIR=${DRN_SAVE_DIR}"
fi
python eval.py drn --cuda --ensemble -t=${DRN_SAVE_DIR}/1/ --output_index=0
popd
if [ ${_ABS} == 0 ];
then
  DRN_SAVE_DIR=${DRN_SAVE_DIR:3}
  DRN_TEST_MAT=${DRN_TEST_MAT:3}
  echo "DRN_SAVE_DIR=${DRN_SAVE_DIR}"
fi
python VSR/Tools/DataProcessing/NTIRE19Denoise.py --results=Results/drn/1/ --save_dir=${DRN_SAVE_DIR}/2/
echo " [*] Processing done. Results are in ${DRN_SAVE_DIR}/2/results.mat"
echo "     PNG files are saved in VideoSuperResolution/Results/drn/1/"
popd
if [ ${_ABS} == 0 ];
then
  DRN_SAVE_DIR=${DRN_SAVE_DIR:3}
  DRN_TEST_MAT=${DRN_TEST_MAT:3}
  echo "DRN_SAVE_DIR=${DRN_SAVE_DIR}"
fi
