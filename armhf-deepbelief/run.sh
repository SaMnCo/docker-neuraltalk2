#!/bin/sh
# This script runs the deep belief on a single image ($1)
# and extracts the highest probability of result

if [ "x$1" = "x" ]
then
	echo "Usage run.sh /path/to/image/to/analyze.jpg"
	exit 0
fi

ROOT_DIR="/opt/deep-belief/DeepBeliefSDK"
WEB_DIR="/data/www"
OUT_DIR="/data/output"
JSON_FILE="vis.json"
IMAGE="$1"
NETWORK="ccv2012.ntwk"
# NETWORK="jetpac.ntwk"

if [ ! -f "${WEB_DIR}/${JSON_FILE}" ] 
then
	echo "[]" > "${WEB_DIR}/${JSON_FILE}"
fi

# Folders are not well transported by git, making sure it is there
[ ! -d "${WEB_DIR}/imgs" ] && mkdir -p "${WEB_DIR}/imgs"

# Collecting data from analysis
# First we use the default j
"${ROOT_DIR}/source"/jpcnn -i "${IMAGE}" -n "${ROOT_DIR}/networks/${NETWORK}" -m s | sort > /tmp/tmp.result

# extracting the best value
RESULT="$(cat /tmp/tmp.result | tail -n1 | cut -f2-)"
# Transforming the result set in a JSON table
JSON_RESULT="[]"
while read line
do 
	PROBA=$(echo $line | cut -f1 -d" " )
	VALUE=$(echo $line | cut -f2- -d" ")
	JSON_RESULT=$(echo ${JSON_RESULT} | jq ". + [{ \"value\": \"${VALUE}\", \"proba\": \"${PROBA}\" }]")
done < /tmp/tmp.result

# Computing next index of image based on the existing result set
if [ $(ls "${WEB_DIR}/imgs" | wc -l ) -eq 0 ]
then
	NEXT="00001"
else
	NEXT=$( printf "%05g" $(expr $(ls "${WEB_DIR}/imgs" | sort | tail -n1 | cut -f1 -d"." | cut -f2 -d"_") + 1))
fi 

# Creating a mini version of the image for display
convert "${IMAGE}" -resize 256x256 "${WEB_DIR}"/imgs/img_${NEXT}.jpg
cp "${IMAGE}" "${OUT_DIR}/"

# Adding image to the visualization file
cat "${WEB_DIR}/${JSON_FILE}" | jq ". + [ {\"caption\": \"${RESULT}\", \"image_id\": \"${NEXT}\", \"source_image\": \"${IMAGE}\", \"list_proba\": ${JSON_RESULT} }]" > /tmp/tmp.file && \
	mv /tmp/tmp.file "${WEB_DIR}/${JSON_FILE}"

