# What is it?

This is a set of bash scripts and Magisk module for patching system `JAR` files and `SO` files of Android.  

Magisk module does following things:

- substitutes JARs in `/system/framework` dir
- remounts folders in `/apex/` to be writeable (why? read `APEX` section)
- substitutes JARs in `/apex/` (temporarily or permanently)

# Why?

Sometimes tools like Frida or XPosed/LSPosed got detected by app under research, so we need to use some **uncommon techniques** to bypass detection. One of such technique is patching system libraries (`.jar` files, `.so` files) to execute code from them as soon as app load them into memory.

# How to use?

1. Download latest [apktool.jar](https://github.com/iBotPeaches/Apktool/releases) and put it in this folder
2. Choose JAR file you want to modify on your Android from `/system/framework`
3. Download JAR from device (via ADB) and put it in this folder under any name (for example `my.jar`)
4. Modify variables in `*.sh` files according to comments on top
5. Run `./jar_to_smali.sh my.jar`, after run you will get `my.jar.smali` folder
6. Modify SMALI files in `my.jar.smali` as you wish
7. Run `smali_to_jar.sh my.jar` to build JAR from updated SMALI files (updated JAR will be located in `magisk_module/system/framework/my.jar`)
8. Build Magisk module for replacing original JARs: `./build_magisk_module.sh`
9. Push magisk module (`jarpatcher.zip`) to device via ADB, install magisk module and reboot device to apply changes: `adb push jarpatcher.zip /sdcard/ && adb shell su -c "magisk --install-module /sdcard/jarpatcher.zip" && adb reboot`
	- if you modified JAR from APEX(`/apex/`), see `How to replace JAR in APEX?` section below
10. Enjoy modified JAR! Or not if you caught a boot loop, then [here is how to easily fix it](#what-to-do-if-you-catch-a-bootloop-after-your-patching)

# Patches! (for JARs)

This repo contains most useful patches (`patches/`) for reverse-engineering which you can apply to your device:

- `sslunpinning` - makes global unpinning in system for all apps on Java level which using Conscrypt library (almost 80% of apps).
- `set_webview_debuggable` - enables DevTools for WebViews systemwide so you can debug JavaScript in them from Desktop via `chrome://inspect/#devices` 
- `hide_debug_mode` - hides USB Debugging enabled in Developer options, so apps will not be able to detect it

## How to apply patches?

1. Do steps 1-5 from [How to use?](#how-to-use) section for the JAR library which you want to patch (each file contains library name and file name).
2. Just run the patch you interested in! For example: `bash ./patches/ssl_unpinning.sh`

## How to write your own patch?

It is very easy to write your own patches! Just copy&paste any file from `patches/` and see its code, the code is completely self-expanatory. "Patch-engine" is 100% shell-based, the only dependency needed is PERL (preinstalled almost in all Linux-based systems including MacOS).

Each patch consist of following parts:
- `PATCH_IDENTITY` - any unique name of patch to locate it in SMALI code (currently used MD5 hashes, but can be any human-readable name)
- `LIB` - JAR library name which patch will be applied to (after using same name in `./jar_to_smali.sh` script)
- `FILE` - class path to patched file in JAR library
- `REGEX` - PERL-based regex to locate place in SMALI code which must be patched. To escape SMALI code, you can use [this online tool](https://www.regex-escape.com/online-regex-escaper.php)
- `PATCH` - SMALI code which will be added

If you have more questions regarding writing patches, feel free to get in touch with me in Telegram - https://t.me/Asen_17.

# APEX

## Why we need APEX at all? 

Well, most of interesting JARs since Android 10 are distributed in APEX format, which contains `.img` with `.jar` and `.so` libraries. Best explanation of APEX format you may find [here](https://android.googlesource.com/platform/system/apex/+/refs/heads/master/docs/README.md). As far as we want to be able to modify all system libraries, we have to be able to modify libraries provided by APEXes as well.

For example, default Java classes like `java.lang.String` or `java.net.URL` provided to all Android apps via `/apex/com.android.art/javalib/core-oj.jar` library.

## Native utility for interaction with APEX - [apexd](https://android.googlesource.com/platform/system/apex/+/refs/heads/sdk-release/apexd/)

We can interact with APEXes manually via `apexd` binary available on every modern Android:

1. `stop` (stop zygote and all apps which are using files from `/apex/*`)
2. `apexd --unmount-all` (unmount all apex filders)
3. `apexd --otachroot-bootstrap` (mounts all apexes back)
4. `start` (start zygote with user space)

## How to replace JAR inside APEX?

By default, Magisk module from this project contains `service.sh` which remounts some of most interesting APEXes after file system got initialized. This lets you to do substitute JAR and SO libraries in runtime like this:

1. `stop` (stop zygote and all apps which are using files from `/apex/*`)
2. `cp /sdcard/patched-core-oj.jar /apex/com.android.art/javalib/core-oj.jar` (patch)
4. `start` (start zygote with user space)

After system boots, patched version of `core-oj.jar` will be loaded in all apps. 

If you need to modify some other APEXes, edit `service.sh` (see `REMOUNTING APEXES` comment). 

**IMPORTANT!** Patching like this will not make permanent changes for APEXes, after reboot you will have to repeat this process again. If you want changes to be permanent after each system reboot, see `PERMANENT CHANGES IN APEXES` comment in `service.sh` and rebuild Magisk module.

# Extra advices

1. Enable Magisk Hide ("magisk modifications are reverted for processes on hidelist") and install [PlayIntegrityFix module](https://github.com/chiteroman/PlayIntegrityFix) to stay stealth.
2. Add researchable app to Magisk Hide list

# What to do if you catch a bootloop after your patching?

1. Flash TWRP into recovery partition
2. Boot TWRP
3. In TWRP go to `Advanced -> File Manager`
4. Remove Magisk module folder `/data/adb/modules/jarpatcher`
5. Reboot to system

# Additional readings

1. [Magisk module structure guide](https://topjohnwu.github.io/Magisk/guides.html)
2. [APEX format](https://android.googlesource.com/platform/system/apex/+/refs/heads/master/docs/README.md)