#!/bin/bash

SCRIPT_PATH=$(dirname "$(realpath $0)")
# this is the name of JAR you adb-pulled from your device (it can be any jar from /system/framework or /apex/)
JAR_NAME=$1
# name of latest ApkTool you downloaded from GitHub, update it to your name
LATEST_APKTOOL_JAR="apktool_2.9.3.jar"
# ApkTool need this flag to build JAR (for APK no need)
API_LEVEL=35

# build DEX from SMALI
cd ${SCRIPT_PATH}
java -jar ${LATEST_APKTOOL_JAR} b ${SCRIPT_PATH}/${JAR_NAME}.smali --api-level ${API_LEVEL}
cd ${SCRIPT_PATH}/${JAR_NAME}.smali/dist
jar -xf ${JAR_NAME}
cp ${SCRIPT_PATH}/${JAR_NAME}.smali/dist/*.dex ${SCRIPT_PATH}/${JAR_NAME}.dex/

# compile JAR with updated DEX
cd ${SCRIPT_PATH}/${JAR_NAME}.dex
jar cf ${JAR_NAME} .

# move updated JAR to magisk module
mv ${SCRIPT_PATH}/${JAR_NAME}.dex/${JAR_NAME} ${SCRIPT_PATH}/magisk_module/system/framework/${JAR_NAME}