Bluetooth stack audio bitrate changer for SBC + aptX & aptX-HD enabler Module.
Increases stack bitrate for audio when SBC codec is used and enables aptX codec on supported devices (Qualcomm).
Tested on Redmi 4X. Possibly (???) works on other devices.
NO WORK on Lineage and Lineage-based ROMs (AICP etc).

## Requirements ##
- Redmi 4x??? Let me know if your device works or not. Blacklist will be formed based on your replies.
- MIUI 10 or any Android >=7. Android 6 users should check, but older OS versions defineteley not supported.

## Details ##
BT stack is modified in the way so it uses:
1. aptX / aptXHD if supported by audio
2. If aptX is not supported - SBC codec will be used, but with the following customization:
 - Dual Channel for any audio connection
 - Maximum bitrate depending on your choice during installation. Test it on your headphones. Normally 454 kbit/s is OK with any headphones, personally I use 576 kbit/s without any problems. If something is not working - just re-install the module with new bitrate or uninstall it completely.

These changes will increase a quality of the sound when using wireless audio.

Most likely Lineage OS and Lineage-based OS (like AICP) are not supported - please let me know if Bluetooth cannot be switched on after installing this module. In this case simply delete the module and reboot - everything will be restored.

## ChangeLog ##

v.5 First Release in Repository

v.5.1 Added x86 support in keycheck

v.5.2 Added OS version check

v.5.3 Changed OS version check method
