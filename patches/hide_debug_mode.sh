#!/bin/bash

############################################################
#
# This patch hides USB Debugging enabled in Developer options
#
############################################################

# functions
source $(dirname $(realpath "$0"))/_.sh

PATCH_IDENTITY=b781f13b7b02e84192f476c7a01cc488
LIB_NAME='framework.jar'
FILE='android/provider/Settings$Global.smali'
REGEX='.method public static greylist-max-r getStringForUser\(Landroid\/content\/ContentResolver;Ljava\/lang\/String;I\)Ljava\/lang\/String;.*?\.line \d+\n'
PATCH=$(cat << EOF
	$(android_logcat $LIB_NAME"_getStringForUser")
	const-string v0, "development_settings_enabled"
    invoke-virtual {p1, v0}, Ljava/lang/String;->equals(Ljava/lang/Object;)Z
    move-result v0
    if-eqz v0, :notEquals
    const-string v0, "0"
    return-object v0
    :notEquals
EOF
)
patch_insert_after "$PATCH_IDENTITY" "$LIB_NAME" "$REGEX" "$PATCH" "$FILE"