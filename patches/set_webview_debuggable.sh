#!/bin/bash

############################################################
#
# Enables DevTools in each WebView in system,
# so you can attach to it from desktop Chromium via url:
# chrome://inspect/#devices 
#
############################################################

# functions
source $(dirname $(realpath "$0"))/_.sh

PATCH_IDENTITY=29119a83d8121a6a15eb7ca15ab02d89
LIB_NAME='framework.jar'
FILE='android/webkit/WebView.smali'
REGEX='.method public whitelist loadUrl\(Ljava\/lang\/String;\)V.*?\.line \d+\n'
PATCH=$(cat << EOF
    $(android_logcat $LIB_NAME"loadUrl(String)")
    const/4 v0, 0x1
    invoke-static {v0}, Landroid/webkit/WebView;->setWebContentsDebuggingEnabled(Z)V
EOF
)
patch_insert_after "$PATCH_IDENTITY" "$LIB_NAME" "$REGEX" "$PATCH" "$FILE"

PATCH_IDENTITY=70d1d3653c1a53425e9e5ba97f0f44f9
LIB_NAME='framework.jar'
FILE='android/webkit/WebView.smali'
REGEX='.method public whitelist loadUrl\(Ljava\/lang\/String;Ljava\/util\/Map;\)V.*?\.line \d+\n'
PATCH=$(cat << EOF
    $(android_logcat $LIB_NAME"loadUrl(String, Map)")
    const/4 v0, 0x1
    invoke-static {v0}, Landroid/webkit/WebView;->setWebContentsDebuggingEnabled(Z)V
EOF
)
patch_insert_after "$PATCH_IDENTITY" "$LIB_NAME" "$REGEX" "$PATCH" "$FILE"