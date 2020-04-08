##########################################################################################
#
# Magisk Module Installer Script
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure and implement callbacks in this file
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Config Flags
##########################################################################################

# Set to true if you do *NOT* want Magisk to mount
# any files for you. Most modules would NOT want
# to set this flag to true
SKIPMOUNT=false

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info why you would need this

# Construct your list in the following format
# This is an example
REPLACE_EXAMPLE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here
REPLACE="
"

##########################################################################################
#
# Function Callbacks
#
# The following functions will be called by the installation framework.
# You do not have the ability to modify update-binary, the only way you can customize
# installation is through implementing these functions.
#
# When running your callbacks, the installation framework will make sure the Magisk
# internal busybox path is *PREPENDED* to PATH, so all common commands shall exist.
# Also, it will make sure /data, /system, and /vendor is properly mounted.
#
##########################################################################################
##########################################################################################
#
# The installation framework will export some variables and functions.
# You should use these variables and functions for installation.
#
# ! DO NOT use any Magisk internal paths as those are NOT public API.
# ! DO NOT use other functions in util_functions.sh as they are NOT public API.
# ! Non public APIs are not guranteed to maintain compatibility between releases.
#
# Available variables:
#
# MAGISK_VER (string): the version string of current installed Magisk
# MAGISK_VER_CODE (int): the version code of current installed Magisk
# BOOTMODE (bool): true if the module is currently installing in Magisk Manager
# MODPATH (path): the path where your module files should be installed
# TMPDIR (path): a place where you can temporarily store files
# ZIPFILE (path): your module's installation zip
# ARCH (string): the architecture of the device. Value is either arm, arm64, x86, or x64
# IS64BIT (bool): true if $ARCH is either arm64 or x64
# API (int): the API level (Android version) of the device
#
# Availible functions:
#
# ui_print <msg>
#     print <msg> to console
#     Avoid using 'echo' as it will not display in custom recovery's console
#
# abort <msg>
#     print error message <msg> to console and terminate installation
#     Avoid using 'exit' as it will skip the termination cleanup steps
#
# set_perm <target> <owner> <group> <permission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     this function is a shorthand for the following commands
#       chown owner.group target
#       chmod permission target
#       chcon context target
#
# set_perm_recursive <directory> <owner> <group> <dirpermission> <filepermission> [context]
#     if [context] is empty, it will default to "u:object_r:system_file:s0"
#     for all files in <directory>, it will call:
#       set_perm file owner group filepermission context
#     for all directories in <directory> (including itself), it will call:
#       set_perm dir owner group dirpermission context
#
##########################################################################################
##########################################################################################
# If you need boot scripts, DO NOT use general boot scripts (post-fs-data.d/service.d)
# ONLY use module scripts as it respects the module status (remove/disable) and is
# guaranteed to maintain the same behavior in future Magisk releases.
# Enable boot scripts by setting the flags in the config section above.
##########################################################################################

# Set what you want to display when installing your module

print_modname() {
  ui_print "*******************************"
  ui_print "*Bluetooth bit rate increased**"
  ui_print "****aptX & aptX-HD enabled*****"
  ui_print "*           by @gjf           *"
  ui_print "*******************************"
  ui_print "*Note: TESTED ON REDMI 4X ONLY*"  
  ui_print "*******************************"
}

# Copy/extract your module files into $MODPATH in on_install.

on_install() {
  # The following is the default implementation: extract $ZIPFILE/system to $MODPATH
  # Extend/change the logic to whatever you want
  ui_print "- Extracting module files"
  unzip -o "$ZIPFILE" 'system/*' -d $MODPATH >&2

  if [ "$ARCH32" == "arm" ]; then
    KEYCHECK=keycheck-arm
  else
    KEYCHECK=keycheck-x86
  fi
  # Keycheck binary by someone755 @Github
  unzip -o "$ZIPFILE" 'common/$KEYCHECK' -d $TMPDIR
  KEYCHECK="$TMPDIR/$KEYCHECK"
  chmod 0755 $KEYCHECK

  #Place for check functions
  osver_fn
  #Let's ask which bitrate is needed
  choosebitrate
}

# Only some special files require specific permissions
# This function will be called after on_install is done
# The default permissions should be good enough for most cases

set_permissions() {
  # The following is the default rule, DO NOT remove
  set_perm_recursive $MODPATH 0 0 0755 0644

  # Here are some examples:
  # set_perm_recursive  $MODPATH/system/lib       0     0       0755      0644
  # set_perm  $MODPATH/system/bin/app_process32   0     2000    0755      u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0     2000    0755      u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0     0       0644
}

# You can add more functions to assist your custom script code

# Volume-Key-Selector feature - credits to Zackptg5 for that

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press a Vol Key"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $TMPDIR/events
    if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $TMPDIR/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
    return 1
  else
    return 0
  fi
}

chooseportold() {
  # Calling it first time detects previous input. Calling it second time will do what we want
  $KEYCHECK
  $KEYCHECK
  SEL=$?
  if [ "$1" = "UP" ]; then
    UP=$SEL
  elif [ "$1" = "DOWN" ]; then
    DOWN=$SEL
  elif [ $SEL -eq $UP ]; then
    return 1
  elif [ $SEL -eq $DOWN ]; then
    return 0
  else
    ui_print "   Vol key not detected!"
    abort "   Sorry for that. Aborting!"
  fi
}

choosebitrate() {
  if keytest; then
    FUNCTION=chooseport
  else
    FUNCTION=chooseportold
    ui_print "   ! Legacy device detected! Using old keycheck method"
    ui_print "- Vol Key Programming -"
    ui_print "   Press Vol Up Again:"
    $FUNCTION "UP"
    ui_print "   Press Vol Down"
    $FUNCTION "DOWN"
  fi
    BITRATE=0
    LOOP=0
	while [ $BITRATE -eq 0 ]; do
		ui_print " "
		ui_print " - Select Bitrate for SBC codec - ($LOOP)"
		ui_print "   Choose which bitrate you want to install:"
		ui_print "   Vol- = 454 kbit/s (works in most cases), Vol+ = higher"
		if [ $LOOP -eq 10 ]; then
			BITRATE=454
			break
		fi
		$((++LOOP))
		if $FUNCTION; then BITRATE=454
			else 
				ui_print " "
				ui_print "   Vol- = 482 kbit/s, Vol+ = higher"
				if $FUNCTION; then BITRATE=482
					else 
						ui_print " "
						ui_print "   Vol- = 486 kbit/s, Vol+ = higher"
						if $FUNCTION; then BITRATE=486
							else
								ui_print " "
								ui_print "   Vol- = 576 kbit/s, Vol+ = higher"
								if $FUNCTION; then BITRATE=576
									else
										ui_print " "
										ui_print "   Vol- = 800 kbit/s (not recommended), Vol+ = start from the beginning"
										if $FUNCTION; then BITRATE=800
										fi
								fi
						fi
				fi
		fi
	done
  ui_print "   You have chosen $BITRATE kbit/s"
  cp -afr $MODPATH/system/lib/hw/BITRATES/$(echo $BITRATE)/bluetooth.default.so $MODPATH/system/lib/hw/bluetooth.default.so
  rm -rf $MODPATH/system/lib/hw/BITRATES
}

osver_fn() {
# Variables
DEVFND=0
SDK_VER=23
SDK_VER_MAX=29
# SDK check
  if [ $API -ge $SDK_VER ] && [ $API -lt $SDK_VER_MAX ]; then
    ui_print "SDK$API detected. It is supported."
    DEVFND=1
    break
  fi
# Abort if no match
if [ $DEVFND == 0 ]; then
  abort "Android is older than Android 6, newer than Android 9 or modified build.prop! Aborting."
fi
}
