#!/system/bin/sh

MODDIR=${0%/*}

remount_apex_writable() {
    local apex_pkg_name="$1"
    mkdir /data/local/jarpatcher_tmp/${apex_pkg_name}
    # TODO: generate image based on original APEX size (now used always 100M)
	cp ${MODDIR}/ext4-clean-100M.img /data/local/jarpatcher_tmp/${apex_pkg_name}/mod.img
	mkdir /data/local/jarpatcher_tmp/${apex_pkg_name}/mnt
	mount -t ext4 /data/local/jarpatcher_tmp/${apex_pkg_name}/mod.img /data/local/jarpatcher_tmp/${apex_pkg_name}/mnt
	cp -pr /apex/${apex_pkg_name}/* /data/local/jarpatcher_tmp/${apex_pkg_name}/mnt/
	touch /data/local/jarpatcher_tmp/${apex_pkg_name}/mnt/cracked.txt
	umount /data/local/jarpatcher_tmp/${apex_pkg_name}/mnt
	umount /apex/${apex_pkg_name}
	mount -t ext4 /data/local/jarpatcher_tmp/${apex_pkg_name}/mod.img /apex/${apex_pkg_name}
	# TODO: make sure these SELinux contexts exist in system
	chcon -R u:object_r:system_file:s0 /apex/${apex_pkg_name}
	chcon -R u:object_r:system_lib_file:s0 /apex/${apex_pkg_name}/lib*
}

rm -rf /data/local/jarpatcher_tmp
mkdir -p /data/local/jarpatcher_tmp

##### REMOUNTING APEXES #####

# APEX'es which contains JAR/so you want to patch
# (see at: /apex/*)
remount_apex_writable "com.android.art"       # contains "javalib/core-oj.jar" with all JVM default classes
remount_apex_writable "com.android.conscrypt" # contains "javalib/conscrypt.jar" with "TrustManagerImpl.class" used to bypass SSLPinning
# add any other packages below if you interested in other APEXes similaly...

##### PERMANENT CHANGES IN APEXES #####

# (UNCOMMENT if any APEX files substituted!)
#stop

# (assuming that modified JARS are inside Magisk module, in system/framework folder after building with smali_to_jar.sh script)
# mv /system/framework/core-oj.jar /apex/com.android.art/javalib/core-oj.jar 
# mv /system/framework/conscrypt.jar /apex/com.android.conscrypt/javalib/conscrypt.jar
# replace original APEXes with your patched ones similarly...

# (UNCOMMENT if any APEX files substituted!)
#debug_ramdisk/su -c 'start'
