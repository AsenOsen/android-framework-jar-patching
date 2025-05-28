#!/bin/bash

############################################################
#
# This patch is based on Frida's most known SSLUnpinning script:
# https://codeshare.frida.re/@akabe1/frida-multiple-unpinning/
#
############################################################

# functions
source $(dirname $(realpath "$0"))/_.sh

# patch #1: verifyChain
PATCH_IDENTITY=b3d42b37dafdec79a6c4b03df1a24801
LIB='conscrypt.jar'
FILE="com/android/org/conscrypt/TrustManagerImpl.smali"
REGEX='.method private greylist-max-o verifyChain\(Ljava\/util\/List;Ljava\/util\/List;Ljava\/lang\/String;Z\[B\[B\)Ljava\/util\/List;.*?\.line \d+\n'
PATCH=$(cat << EOF
	$(android_logcat $LIB"_verifyChain")
	return-object p1
EOF
)
patch_insert_after "$PATCH_IDENTITY" "$LIB" "$REGEX" "$PATCH" "$FILE"

# patch #2: checkTrustedRecursive
PATCH_IDENTITY=e81e9cc2f4ddda4955e42da3a277ec9a
LIB='conscrypt.jar'
FILE="com/android/org/conscrypt/TrustManagerImpl.smali"
REGEX='.method private greylist-max-o checkTrustedRecursive\(\[Ljava\/security\/cert\/X509Certificate;\[B\[BLjava\/lang\/String;ZLjava\/util\/ArrayList;Ljava\/util\/ArrayList;Ljava\/util\/Set;\)Ljava\/util\/List;.*?\.line \d+\n'
PATCH=$(cat << EOF
	$(android_logcat $LIB"_checkTrustedRecursive")
	new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    return-object v0
EOF
)
patch_insert_after "$PATCH_IDENTITY" "$LIB" "$REGEX" "$PATCH" "$FILE"

# patch #3: checkTrustedRecursive (variation)
PATCH_IDENTITY=e81e9cc2f4ddda4955e42da3a277ec9a-2
LIB='conscrypt.jar'
FILE="com/android/org/conscrypt/TrustManagerImpl.smali"
REGEX='.method private blacklist checkTrustedRecursive\(\[Ljava\/security\/cert\/X509Certificate;\[B\[BLjava\/lang\/String;ZLjava\/util\/List;Ljava\/util\/List;Ljava\/util\/Set;\)Ljava\/util\/List;.*?\.line \d+\n'
PATCH=$(cat << EOF
	$(android_logcat $LIB"_checkTrustedRecursive")
	new-instance v0, Ljava/util/ArrayList;
    invoke-direct {v0}, Ljava/util/ArrayList;-><init>()V
    return-object v0
EOF
)
patch_insert_after "$PATCH_IDENTITY" "$LIB" "$REGEX" "$PATCH" "$FILE"
