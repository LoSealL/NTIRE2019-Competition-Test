#!/usr/bin/env bash
# Author: Wenyi Tang
# Date: Mar. 18 2019
# Email: wenyitang@outlook.com

#RSR_TEST_DIR=
#RSR_SAVE_DIR=
if [ ${RSR_SAVE_DIR:0:1} == '/' ];
then
  _ABS=1
else
  _ABS=0
fi
if [ -z ${_PATCH_SIZE} ];
then
  _PATCH_SIZE=768
fi
if [ -z ${_STRIDE} ];
then
  _STRIDE=760
fi

if [ ! -e VideoSuperResolution ];
then
  git clone https://github.com/LoSealL/VideoSuperResolution -b ntire_2019
fi

pushd VideoSuperResolution
if [ ${_ABS} == 0 ];
then
  RSR_SAVE_DIR=../${RSR_SAVE_DIR}
  RSR_TEST_DIR=../${RSR_TEST_DIR}
fi
if [ ! -e setup.py ];
then
  echo " [!] Can't find setup.py file! Make sure you are in the right place!"
fi

echo "RSR_TEST_DIR=${RSR_TEST_DIR}"
echo "RSR_SAVE_DIR=${RSR_SAVE_DIR}"
echo "Patch size=${_PATCH_SIZE}, stride=${_STRIDE}"

pip install -q -e .
python prepare_data.py --filter=rsr -q
echo " [*] Model extracted into Results/rsr/save"
python VSR/Tools/DataProcessing/NTIRE19RSR.py --ref_dir=${RSR_TEST_DIR} --patch_size=${_PATCH_SIZE} --stride=${_STRIDE} --save_dir=${RSR_SAVE_DIR}/1/
pushd VSRTorch
if [ ${_ABS} == 0 ];
then
  RSR_SAVE_DIR=../${RSR_SAVE_DIR}
  RSR_TEST_DIR=../${RSR_TEST_DIR}
  echo "RSR_SAVE_DIR=${RSR_SAVE_DIR}"
fi
python eval.py rsr --cuda --ensemble -t=${RSR_SAVE_DIR}/1/
popd
if [ ${_ABS} == 0 ];
then
  RSR_SAVE_DIR=${RSR_SAVE_DIR:3}
  RSR_TEST_DIR=${RSR_TEST_DIR:3}
  echo "DRN_SAVE_DIR=${DRN_SAVE_DIR}"
fi
python VSR/Tools/DataProcessing/NTIRE19RSR.py --ref_dir=${RSR_TEST_DIR} --patch_size=${_PATCH_SIZE} --stride=${_STRIDE} --results=Results/rsr/1/ --save_dir=${RSR_SAVE_DIR}/2/
echo " [*] Processing done. Results are in ${RSR_SAVE_DIR}/2/"
popd
if [ ${_ABS} == 0 ];
then
  RSR_SAVE_DIR=${RSR_SAVE_DIR:3}
  RSR_TEST_DIR=${RSR_TEST_DIR:3}
  echo "DRN_SAVE_DIR=${DRN_SAVE_DIR}"
fi
