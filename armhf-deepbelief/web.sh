#!/bin/sh

WEB_DIR="/data/www"

cd "${WEB_DIR}"
python -m SimpleHTTPServer
