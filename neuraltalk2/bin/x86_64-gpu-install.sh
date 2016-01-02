#!/bin/bash

DATASET="${DATASET_SRC}"
MODEL="$1"
IMAGES="$2"

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
HAS_IMAGES=$(ls | wc -l)
if [ ${HAS_IMAGES} -eq 0 ]
then
	for i in $(seq 1 1 10)
	do 
		wget -qbc http://cs.stanford.edu/people/karpathy/neuraltalk2/imgs/img${i}.jpg
	done
fi

# Run command
cd /opt/neural-networks/neuraltalk2
/opt/neural-networks/torch/install/bin/th eval.lua -model "${MODEL}" -image_folder "${IMAGES}" -num_images -1 &

python -m SimpleHTTPServer 
