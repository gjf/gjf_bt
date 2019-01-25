##########################################################################################
#
# Magisk Module Template Config Script
# by topjohnwu
#
##########################################################################################
##########################################################################################
#
# Instructions:
#
# 1. Place your files into system folder (delete the placeholder file)
# 2. Fill in your module's info into module.prop
# 3. Configure the settings in this file (config.sh)
# 4. If you need boot scripts, add them into common/post-fs-data.sh or common/service.sh
# 5. Add your additional or modified system properties into common/system.prop
#
##########################################################################################

##########################################################################################
# Configs
##########################################################################################

# Set to true if you need to enable Magic Mount
# Most mods would like it to be enabled
AUTOMOUNT=true

# Set to true if you need to load system.prop
PROPFILE=true

# Set to true if you need post-fs-data script
POSTFSDATA=false

# Set to true if you need late_start service script
LATESTARTSERVICE=false

##########################################################################################
# Installation Message
##########################################################################################

# Set what you want to show when installing your mod

print_modname() {
  ui_print "*******************************"
  ui_print "*Bluetooth bit rate increased**"
  ui_print "****aptX & aptX-HD enabled*****"
  ui_print "*           by @gjf           *"
  ui_print "*******************************"
  ui_print "*Note: TESTED ON REDMI 4X ONLY*"  
  ui_print "*******************************"
}

##########################################################################################
# Replace list
##########################################################################################

# List all directories you want to directly replace in the system
# Check the documentations for more info about how Magic Mount works, and why you need this

# This is an example
REPLACE="
/system/app/Youtube
/system/priv-app/SystemUI
/system/priv-app/Settings
/system/framework
"

# Construct your own list here, it will override the example above
# !DO NOT! remove this if you don't need to replace anything, leave it empty as it is now
REPLACE="
"

##########################################################################################
# Permissions
##########################################################################################

set_permissions() {
  # Only some special files require specific permissions
  # The default permissions should be good enough for most cases

  # Here are some examples for the set_perm functions:

  # set_perm_recursive  <dirname>                <owner> <group> <dirpermission> <filepermission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm_recursive  $MODPATH/system/lib       0       0       0755            0644

  # set_perm  <filename>                         <owner> <group> <permission> <contexts> (default: u:object_r:system_file:s0)
  # set_perm  $MODPATH/system/bin/app_process32   0       2000    0755         u:object_r:zygote_exec:s0
  # set_perm  $MODPATH/system/bin/dex2oat         0       2000    0755         u:object_r:dex2oat_exec:s0
  # set_perm  $MODPATH/system/lib/libart.so       0       0       0644

  # The following is default permissions, DO NOT remove
  set_perm_recursive  $MODPATH  0  0  0755  0644
}

##########################################################################################
# Custom Functions
##########################################################################################

# This file (config.sh) will be sourced by the main flash script after util_functions.sh
# If you need custom logic, please add them here as functions, and call these functions in
# update-binary. Refrain from adding code directly into update-binary, as it will make it
# difficult for you to migrate your modules to newer template versions.
# Make update-binary as clean as possible, try to only do function calls in it.

# Volume-Key-Selector feature - credits to Zackptg5 for that

keytest() {
  ui_print " - Vol Key Test -"
  ui_print "   Press a Vol Key"
  (/system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events) || return 1
  return 0
}

chooseport() {
  #note from chainfire @xda-developers: getevent behaves weird when piped, and busybox grep likes that even less than toolbox/toybox grep
  while true; do
    /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $INSTALLER/events
    if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUME >/dev/null`); then
      break
    fi
  done
  if (`cat $INSTALLER/events 2>/dev/null | /system/bin/grep VOLUMEUP >/dev/null`); then
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
  if [ "$1" == "UP" ]; then
    UP=$SEL
  elif [ "$1" == "DOWN" ]; then
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
  # Keycheck binary by someone755 @Github, idea for code below by Zappo @xda-developers
  if "$ARCH32" == "arm"; then
	KEYCHECK=$INSTALLER/common/keycheck-arm
		else
			KEYCHECK=$INSTALLER/common/keycheck-x86
  fi
  chmod 755 $KEYCHECK

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
	while [ $BITRATE -eq 0 ]; do
		ui_print " "
		ui_print " - Select Bitrate for SBC codec -"
		ui_print "   Choose which bitrate you want to install:"
		ui_print "   Vol- = 454 kbit/s (works in most cases), Vol+ = higher"
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
