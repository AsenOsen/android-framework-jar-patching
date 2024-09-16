#!/bin/bash

patch_banner() {
    local identity=$1
    echo "    ##### jarpatcher:$identity"
}

patch_remove() {
    local identity="$1"
    local file="$2"
    local marker=$(patch_banner "$identity")
    perl -i -0777 -pe 's/('"\n$marker"'.*'"$marker\n\n"')//gs' "$file"
}

patch_insert_after() {
    local identity=$1
    local marker=$(patch_banner "$identity")
    local lib="$2"
    local regx="$3"
    local code=$(printf '%s' "$4" | sed 's/[][\.*^$(){}?+|\/]/\\&/g')
    local class="$5"

    SCRIPT_PATH=$(dirname $(realpath "$0"))
    LIB_PATH="$SCRIPT_PATH""/../$lib.smali"
    SMALI_PATH=$(find $LIB_PATH | grep "$class")
    file=$SMALI_PATH

    if [ ! -e "$file" ]; then
        echo "Could not find '$class' in '$lib' to apply patch '$identity'. Make sure '$lib' library pulled and decompiled!"
        return
    fi

    patch_remove "$identity" "$file"
    if grep -q $identity $file; then
        echo "Could not remove old patch '$identity'!"
        return
    fi

    perl -i -0777 -pe 's/('"$regx"')/$1'"\n$marker\n$code\n$marker\n\n"'/s' "$file"
    if grep -q $identity $file; then
        echo "Patch '$identity' successfully applied!"
    else
        echo "Patch '$identity' was not applied. Probably smali code was changed and do not match signature anymore."
    fi
}

# Method for logging some strings in logcat
# (be careful, some smali methods do not have v0 available)
android_logcat() {
    LOG_IDENTITY=$1
    RANDOM_NUMBER=$(( RANDOM % 100000 ))
    LABEL="99$RANDOM_NUMBER"
    CODE=$(cat << EOF
    :try_start_$LABEL
    const-string v0, "$LOG_IDENTITY"
    invoke-static {v0, v0}, Landroid/util/Log;->i(Ljava/lang/String;Ljava/lang/String;)I
    :try_end_$LABEL
    .catchall {:try_start_$LABEL .. :try_end_$LABEL} :catchall_$LABEL
    goto :try_exit_$LABEL
    :catchall_$LABEL
    move-exception v0
    :try_exit_$LABEL
EOF
    )
    echo "$CODE"
}
