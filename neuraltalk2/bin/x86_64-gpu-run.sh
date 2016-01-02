#!/bin/bash

MODEL="$1"
IMAGES="/data/images"

. /opt/neural-networks/torch/install/bin/torch-activate

MODEL="$(find /data/model -name '*.t7')"

# Run command
cd /opt/neural-networks/neuraltalk2
/opt/neural-networks/torch/install/bin/th eval.lua \
	-model "${MODEL}" \
	-image_folder "${IMAGES}" \
	-num_images -1 &
