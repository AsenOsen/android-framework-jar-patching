# What is it?

This is a set of bash scripts and tiny Magisk module for patching system JAR files of Android.

# Why?

Sometimes tools like Frida or XPosed/LSPosed got detected by app under research, so we need to use some uncommon techniques to bypass detection. One of such technique is patching system libraries (`.jar` files, `.so` files) to execute code from them as soon as app load them into memory.

# How to use this repo?

1. Download latest [apktool.jar](https://github.com/iBotPeaches/Apktool/releases) and put it in this folder
2. Choose JAR file you want to modify on your Android from `/system/framework`
3. Download JAR from device (via ADB) and put it in this folder
4. Modify variables in `*.sh` files according to comments on top
5. Run `./jar_to_smali.sh`, after run you will get `your-jar-file.jar.smali` folder
6. Modify SMALI files in `your-jar-file.jar.smali` as you wish
7. Run `smali_to_jar.sh` to build JAR from updated SMALI files (updated JAR will be located in `magisk_module/system/framework/`)
8. Build Magisk module for replacing origina JAR in `/system/framework`: `./build_magisk_module.sh`
9. Push built magisk module (`jarpatcher.zip`) to device (via ADB) and install ZIP via Magisk on device
10. Enjoy modified JAR!

# Extra advices

1. Enable Magisk Hide ("magisk modifications are reverted for processes on hidelist") to stay stealth.
2. Add researchable app to Magisk Hide list

# What to do if you catch a bootloop after your patching?

1. Flash TWRP into recovery partition
2. Boot TWRP
3. In TWRP go to `Advanced -> File Manager`
4. Remove Magisk module folder `/data/adb/modules/jarpatcher`
5. Reboot to system

# Additional readings

1. [Magisk module structure guide](https://topjohnwu.github.io/Magisk/guides.html)
2. [Patching apex libraries](https://xdaforums.com/t/question-override-libart-so-and-other-runtime-apex-components-on-android-10.4136983/)
