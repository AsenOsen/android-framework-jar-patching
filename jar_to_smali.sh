#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath $0)")
# this is the name of JAR you adb-pulled from your device (it can be any jar from /system/framework or /apex/)
JAR_NAME=$1
# name of latest ApkTool you downloaded from GitHub, update it to your name
LATEST_APKTOOL_JAR="apktool_2.9.3.jar"

# unpack JAR (to DEX files)
rm -rf ${SCRIPT_PATH}/${JAR_NAME}.dex
mkdir ${SCRIPT_PATH}/${JAR_NAME}.dex
cp ${SCRIPT_PATH}/${JAR_NAME} ${SCRIPT_PATH}/${JAR_NAME}.dex/
cd ${SCRIPT_PATH}/${JAR_NAME}.dex
jar -xf ${JAR_NAME}
rm ${JAR_NAME}

# decompile DEX to SMALI (after this you may edit SMALI code of library)
cd ${SCRIPT_PATH}
rm -rf ${SCRIPT_PATH}/${JAR_NAME}.smali
java -jar ${LATEST_APKTOOL_JAR} d ${SCRIPT_PATH}/${JAR_NAME} -o ${SCRIPT_PATH}/${JAR_NAME}.smali