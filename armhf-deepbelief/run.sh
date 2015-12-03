#!/bin/sh
# This script runs the deep belief on a single image ($1)
# and extracts the highest probability of result

ROOT_DIR="/opt/deep-belief/DeepBeliefSDK"
WEB_DIR="/data/www"
OUT_DIR="/data/output"
JSON_FILE="vis.json"

if [ ! -f "${WEB_DIR}/${JSON_FILE}" ] 
then
	echo "[]" > "${WEB_DIR}/${JSON_FILE}"
fi

IMAGE="$1"
cd "${ROOT_DIR}/source"
RESULT=$(./jpcnn -i "${IMAGE}" -n "${ROOT_DIR}/networks/jetpac.ntwk" -m s | sort | tail -n1 | cut -f2-)

if [ $(ls "${WEB_DIR}/imgs" | wc -l ) -eq 0 ]
then
	NEXT="00001"
else
	NEXT=$( printf "%05g" $(expr $(ls "${WEB_DIR}/imgs" | sort | tail -n1 | cut -f1 -d"." | cut -f2 -d"_") + 1))
fi 

echo $NEXT $RESULT
convert "${IMAGE}" -resize 256x256 "${WEB_DIR}"/imgs/img_${NEXT}.jpg
sleep 1
mv "${IMAGE}" "${OUT_DIR}/"

cd ${WEB_DIR}

cat "${JSON_FILE}" | jq ". + [ {\"caption\": \"${RESULT}\", \"image_id\": \"${NEXT}\" }]" > tmp.file && \
	mv tmp.file "${JSON_FILE}"


