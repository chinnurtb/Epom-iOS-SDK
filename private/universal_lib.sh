# Version 2.0 (updated for Xcode 4, with some fixes)
# Changes:
#    - Works with xcode 4, even when running xcode 3 projects (Workarounds for apple bugs)
#    - Faster / better: only runs lipo once, instead of once per recursion
#    - Added some debugging statemetns that can be switched on/off by changing the DEBUG_THIS_SCRIPT variable to "true"
#    - Fixed some typos
# 
# Purpose:
#   Create a static library for iPhone from within XCode
#   Because Apple staff DELIBERATELY broke Xcode to make this impossible from the GUI (Xcode 3.2.3 specifically states this in the Release notes!)
#   ...no, I don't understand why they did this!
#
# Author: Adam Martin - http://twitter.com/redglassesapps
# Based on: original script from Eonil (main changes: Eonil's script WILL NOT WORK in Xcode GUI - it WILL CRASH YOUR COMPUTER)
#
# More info: see this Stack Overflow question: http://stackoverflow.com/questions/3520977/build-fat-static-library-device-simulator-using-xcode-and-sdk-4

#################[ Tests: helps workaround any future bugs in Xcode ]########

#uncomment line below to skip universal libraries building
#exit

DEBUG_THIS_SCRIPT="false"

LIB_OUTPUT_DIR=$1

if [ $DEBUG_THIS_SCRIPT = "true" ]
then
echo "########### TESTS #############"
echo "Use the following variables when debugging this script; note that they may change on recursions"
echo "BUILD_DIR = $BUILD_DIR"
echo "BUILD_ROOT = $BUILD_ROOT"
echo "CONFIGURATION_BUILD_DIR = $CONFIGURATION_BUILD_DIR"
echo "BUILT_PRODUCTS_DIR = $BUILT_PRODUCTS_DIR"
echo "CONFIGURATION_TEMP_DIR = $CONFIGURATION_TEMP_DIR"
echo "TARGET_BUILD_DIR = $TARGET_BUILD_DIR"
fi

#####################[ part 1 ]##################
# First, work out the BASESDK version number (NB: Apple ought to report this, but they hide it)
#    (incidental: searching for substrings in sh is a nightmare! Sob)

SDK_VERSION=$(echo ${SDK_NAME} | grep -o '.\{3\}$')

# Next, work out if we're in SIM or DEVICE
TARGET_ARCH_OPTION=""
if [ ${PLATFORM_NAME} == "iphonesimulator" ]
then
OTHER_SDK_TO_BUILD=iphoneos${SDK_VERSION}
else
OTHER_SDK_TO_BUILD=iphonesimulator${SDK_VERSION}
TARGET_ARCH_OPTION="-arch \"i386\""
fi

echo "XCode has selected SDK: ${PLATFORM_NAME} with version: ${SDK_VERSION} (although back-targetting: ${IPHONEOS_DEPLOYMENT_TARGET})"
echo "...therefore, OTHER_SDK_TO_BUILD = ${OTHER_SDK_TO_BUILD}"
#
#####################[ end of part 1 ]##################

#####################[ part 2 ]##################
#
# IF this is the original invocation, invoke WHATEVER other builds are required
#
# Xcode is already building ONE target...
#
# ...but this is a LIBRARY, so Apple is wrong to set it to build just one.
# ...we need to build ALL targets
# ...we MUST NOT re-build the target that is ALREADY being built: Xcode WILL CRASH YOUR COMPUTER if you try this (infinite recursion!)
#
#
# So: build ONLY the missing platforms/configurations.

if [ "true" == ${ALREADYINVOKED:-false} ]
then
echo "RECURSION: I am NOT the root invocation, so I'm NOT going to recurse"
else
# CRITICAL:
# Prevent infinite recursion (Xcode sucks)
export ALREADYINVOKED="true"

echo "RECURSION: I am the root ... recursing all missing build targets NOW..."
echo "RECURSION: ...about to invoke: xcodebuild -configuration \"${CONFIGURATION}\" -target \"${TARGET_NAME}\" -sdk \"${OTHER_SDK_TO_BUILD}\" \"${TARGET_ARCH_OPTION}\" ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO"
xcodebuild -configuration "${CONFIGURATION}" -target "${TARGET_NAME}" -sdk "${OTHER_SDK_TO_BUILD}" ${TARGET_ARCH_OPTION} ${ACTION} RUN_CLANG_STATIC_ANALYZER=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

ACTION="build"

#Merge all platform binaries as a fat binary for each configurations.

# Calculate where the (multiple) built files are coming from:
CURRENTCONFIG_DEVICE_DIR=${SYMROOT}/${CONFIGURATION}-iphoneos
CURRENTCONFIG_SIMULATOR_DIR=${SYMROOT}/${CONFIGURATION}-iphonesimulator

echo "Taking device build from: ${CURRENTCONFIG_DEVICE_DIR}"
echo "Taking simulator build from: ${CURRENTCONFIG_SIMULATOR_DIR}"

CREATING_UNIVERSAL_DIR=${SYMROOT}/${CONFIGURATION}-universal
echo "...I will output a universal build to: ${CREATING_UNIVERSAL_DIR}"

# ... remove the products of previous runs of this script
#      NB: this directory is ONLY created by this script - it should be safe to delete!

#rm -rf "${CREATING_UNIVERSAL_DIR}"
#mkdir "${CREATING_UNIVERSAL_DIR}"

# DO NOT erase directory completely. leave already created libraries there
if [ ! -d "${CREATING_UNIVERSAL_DIR}" ]; then
mkdir "${CREATING_UNIVERSAL_DIR}"
fi

#
echo "lipo: for current configuration (${CONFIGURATION}) creating output file: ${CREATING_UNIVERSAL_DIR}/${EXECUTABLE_NAME}"
lipo -create -output "${CREATING_UNIVERSAL_DIR}/${EXECUTABLE_NAME}" "${CURRENTCONFIG_DEVICE_DIR}/${EXECUTABLE_NAME}" "${CURRENTCONFIG_SIMULATOR_DIR}/${EXECUTABLE_NAME}"

if [ -d "${LIB_OUTPUT_DIR}" ]
then
echo "Copy \"${EXECUTABLE_NAME}\" to \"${LIB_OUTPUT_DIR}\""
cp -f "${CREATING_UNIVERSAL_DIR}/${EXECUTABLE_NAME}" "${LIB_OUTPUT_DIR}/${EXECUTABLE_NAME}"
fi 

#########
#
# Added: StackOverflow suggestion to also copy "include" files
#    (untested, but should work OK)
#
if [ -d "${CURRENTCONFIG_DEVICE_DIR}/usr/local/include" ]
then
mkdir -p "${CREATING_UNIVERSAL_DIR}/usr/local/include"
# * needs to be outside the double quotes?
cp "${CURRENTCONFIG_DEVICE_DIR}/usr/local/include/"* "${CREATING_UNIVERSAL_DIR}/usr/local/include"
fi
fi
