#!/bin/bash

DATASET="${DATASET_SRC}"
MODEL="$2"
IMAGES="$3"

. ~/.bashrc

# Assuming the last bit of the URL is the file
SEP="/"
L=$(expr $(grep -o "${SEP}" <<< "${DATASET_SRC}" | wc -l) + 1)
FILE=$(echo "${DATASET_SRC}" | cut -f"${L}" -d"${SEP}")

# Install dataset
cd "${MODEL}"
FIRST_RUN=$(find /data/model/ -name '*.t7')

if [ ! -f "${FIRST_RUN}" ]
then 
	wget -c "${DATASET_SRC}"
	unzip "${FILE}" && rm -f "${FILE}"
fi

MODEL="$(find /data/model -name '*.t7')"

# Copy 10 images for testing
cd "${IMAGES}"
for i in $(seq 1 1 10)
do 
	wget -qbc http://cs.stanford.edu/people/karpathy/neuraltalk2/imgs/img${i}.jpg
done

# Run command
cd /opt/neural-networks/neuraltalk2
/opt/neural-networks/torch/install/bin/th eval.lua -model "${MODEL}" -image_folder "${IMAGES}" -num_images 1000 -batch_size 1 -gpuid -1 &

python -m SimpleHTTPServer 
