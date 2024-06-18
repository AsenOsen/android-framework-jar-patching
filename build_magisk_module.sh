#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath $0)")

cd ${SCRIPT_PATH}/magisk_module
zip -r jarpatcher.zip *
mv ${SCRIPT_PATH}/magisk_module/jarpatcher.zip ${SCRIPT_PATH}
cd ${SCRIPT_PATH}