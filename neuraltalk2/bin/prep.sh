#!/bin/bash


# Download files
cat > /tmp/md5sum.txt << EOF
5750999c8c964077e3c81581170be65b  "${TRAINING}"/captions_train-val2014.zip
68baf1a0733e26f5878a1450feeebc20  "${TRAINING}"/train2014.zip
a3d79f5ed8d289b7a7554ce06a5782b3  "${TRAINING}"/val2014.zip
441315b0ff6932dbfde97731be7ca852  "${TRAINING}"/VGG_ILSVRC_16_layers.caffemodel
c70550f8203a4eaae53d7c39ef34c92d  "${TRAINING}"/VGG_ILSVRC_16_layers_deploy.prototxt
EOF

cd ${TRAINING}

until "x${DONE}" = "x1"
	wget -qc http://msvocds.blob.core.windows.net/annotations-1-0-3/captions_train-val2014.zip
	wget -qc http://msvocds.blob.core.windows.net/coco2014/train2014.zip
	wget -qc http://msvocds.blob.core.windows.net/coco2014/val2014.zip
	wget -qc http://www.robots.ox.ac.uk/~vgg/software/very_deep/caffe/VGG_ILSVRC_16_layers.caffemodel
	wget -qc https://gist.githubusercontent.com/ksimonyan/211839e770f7b538e2d8/raw/0067c9b32f60362c74f4c445a080beed06b07eb3/VGG_ILSVRC_16_layers_deploy.prototxt

	RESULT="$(md5sum -c /tmp/md5sum.txt | grep 'FAILED' | wc -l)"

	if "${RESULT}" = "0"
	then
		DONE=1
	fi
done

# Build the raw JSON file
for file in train2014.zip val2014.zip captions_train-val2014.zip
do 
	unzip "${file}" && rm -f "${file}"
done

# replace image with problem
wget -qc https://msvocds.blob.core.windows.net/images/262993_z.jpg && \
mv 262993_z.jpg train2014/COCO_train2014_000000167126.jpg

# Prepare the raw files
python /opt/neural-networks/prep.py 

# Run the preparation script
python /opt/neural-networks/neuraltalk2/prepro.py  \
	--input_json /data/training/coco_raw.json \
	--num_val 20000 \
	--num_test 20000 \
	--images_root /data/training \
	--word_count_threshold 5 \
	--output_json /data/training/cocotalk.json \
	--output_h5 /data/training/cocotalk.h5

echo "OK, all files downloaded and prep'd! You can safely move to training"
