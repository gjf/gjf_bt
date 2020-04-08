Bluetooth stack audio bitrate changer for SBC + aptX & aptX-HD enabler Module.
Increases stack bitrate for audio when SBC codec is used and enables aptX codec on supported devices (Qualcomm).
Tested on Redmi 4X. Possibly (???) works on other devices.
NO WORK on Lineage and Lineage-based ROMs (AICP etc).

## !!!IMPORTANT NOTICE!!! ##
This module was made for personal use and as a PoC for my article. Probably it will not work on most devices other than mine :)
Anyway - I am not responsible for bricking your device. If it happend - please remove this module.
If you have no custom recovery - installation of buggy modules could be a pain. Please pay attention on it - you wouldn't be able to disable the module in case of bootloop.
Also I cannot guarantee the correct work on non-stable versions of Magisk.
I WILL NEVER RESPOND ON PROBLEMS FROM REPACKED OR EDITED MODULES SOURCED FROM NON-OFFICIAL REPOSITORIES!
(greetings to akseonig and 4pda "repackers")

## Requirements ##
- Redmi 4x??? Let me know if your device works or not. Blacklist will be formed based on your replies. No replies - no blacklist.
- MIUI 10 or any Android >=7. Android 6 users should check, but older OS versions and Android 10 defineteley not supported.

## Details ##
BT stack is modified in the way so it uses:
1. aptX / aptXHD if supported by audio
2. If aptX is not supported - SBC codec will be used, but with the following customization:
 - Dual Channel for any audio connection
 - Maximum bitrate depending on your choice during installation. Test it on your headphones. Normally 454 kbit/s is OK with any headphones, personally I use 576 kbit/s without any problems. If something is not working - just re-install the module with new bitrate or uninstall it completely.

These changes will increase a quality of the sound when using wireless audio.

Most likely Lineage OS and Lineage-based OS (like AICP) are not supported - please let me know if Bluetooth cannot be switched on after installing this module. In this case simply delete the module and reboot - everything will be restored.

## ChangeLog ##
* v.5.6 Android 10 (and newer) is blacklisted

* v.5.5 Implememnted René Schümann aka White-Tiger fix for install.sh, possibly will fix keycheck and infinite loop issues

* v.5.4 Updated keychecks files, updated to latest installation template

* v.5.3 Changed OS version check method

* v.5.2 Added OS version check

* v.5.1 Added x86 support in keycheck

* v.5 First Release in Repository
