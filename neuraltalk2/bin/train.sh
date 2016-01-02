#!/bin/bash

TRAINING="/data/training"
MODEL="/data/model"

. /opt/neural-networks/torch/install/bin/torch-activate

cd /opt/neural-networks/neuraltalk2

# No Fine Tuning
th train.lua \
	-input_h5 "${TRAINING}"/cocotalk.h5 \
	-input_json "${TRAINING}"/cocotalk.json \
	-cnn_proto "${TRAINING}"/VGG_ILSVRC_16_layers_deploy.prototxt \
	-cnn_model "${TRAINING}"/VGG_ILSVRC_16_layers.caffemodel \
	-checkpoint_path "${MODEL}"

# With Fine Tuning
# th train.lua \
# 	-input_h5 "${TRAINING}"/cocotalk.h5 \
# 	-input_json "${TRAINING}"/cocotalk.json \
# 	-cnn_proto "${TRAINING}"/VGG_ILSVRC_16_layers_deploy.prototxt \
# 	-cnn_model "${TRAINING}"/VGG_ILSVRC_16_layers.caffemodel \
# 	-checkpoint_path "${MODEL}"
# 	-finetune_cnn_after 0
# 	-start_from <insert name here
