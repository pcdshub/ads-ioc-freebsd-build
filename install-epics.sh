#!/usr/local/bin/bash

# Function to ask a yes/no question
ask_yes_no() {
    while true; do
        read -p "$1 (yes/no): " answer
        case $answer in
            [Yy]* ) return 0;; # Yes, return 0 (success)
            [Nn]* ) return 1;; # No, return 1 (failure)
            * ) echo "Please answer yes or no.";;
        esac
    done
}

script_path=$(pwd)

# upgrade system to fix curl bug
pkg upgrade -y

# Install required packages
pkg install -y  autoconf automake lang/gcc gmake git perl5 devel/libtool

# create symbolic links for gcc and g++ at the places that epics makefiles expects
ln -sf /usr/local/bin/g++ /usr/bin/g++
ln -sf /usr/local/bin/gcc /usr/bin/gcc

# proxy connection setup for tst network
if ask_yes_no "Are you on tst network?"; then
    export HTTP_PROXY='http://psproxy:3128'
    export HTTPS_PROXY='http://psproxy:3128'
fi

# Set version settings
BASE_MODULE_TAG="R7.0.3.1-1.0.6"
BASE_MODULE_VERSION="R7.0.3.1-1.0.6"
CALC_MODULE_VERSION="R3.7-1.0.1"
SEQ_MODULE_VERSION="R2.2.4-1.1"
SSCAN_MODULE_VERSION="R2.10.2-1.0.0"
ASYN_MODULE_VERSION="R4.39-1.0.1"
AUTOSAVE_MODULE_VERSION="R5.8-2.1.0"
CAPUTLOG_MODULE_VERSION="R3.7-1.0.0"
ETHERCATMC_MODULE_VERSION="R2.1.0-0.1.2"
IOCADMIN_MODULE_VERSION="R3.1.15-1.10.0"
MOTOR_MODULE_VERSION="R6.9-ess-0.0.1"

RE2C_VERSION=3.1

# Set up paths
REG_G="/reg/g"
CDS_GROUP_PCD="/cds/group/pcds"
EPICS_SITE_TOP="$CDS_GROUP_PCD/epics"
BASE_MODULE_PATH="$EPICS_SITE_TOP/base/$BASE_MODULE_VERSION"
ASYN_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/asyn/$ASYN_MODULE_VERSION"
AUTOSAVE_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/autosave/$AUTOSAVE_MODULE_VERSION"
CAPUTLOG_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/caPutLog/$CAPUTLOG_MODULE_VERSION"
CALC_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/calc/$CALC_MODULE_VERSION"
ETHERCATMC_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/ethercatmc/$ETHERCATMC_MODULE_VERSION"
IOCADMIN_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/iocAdmin/$IOCADMIN_MODULE_VERSION"
MOTOR_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/motor/$MOTOR_MODULE_VERSION"
SSCAN_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/sscan/$SSCAN_MODULE_VERSION"
SEQ_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/seq/$SEQ_MODULE_VERSION"
IOC_PATH="$EPICS_SITE_TOP/ioc"
IOC_COMMON_PATH="$IOC_PATH/common"

EPICS_DEPS=$EPICS_SITE_TOP/deps
RE2C=$EPICS_DEPS/RE2C/$RE2C_VERSION


# Set environment variables
export BASE_MODULE_TAG BASE_MODULE_VERSION CALC_MODULE_VERSION SEQ_MODULE_VERSION SSCAN_MODULE_VERSION ASYN_MODULE_VERSION AUTOSAVE_MODULE_VERSION CAPUTLOG_MODULE_VERSION ETHERCATMC_MODULE_VERSION IOCADMIN_MODULE_VERSION MOTOR_MODULE_VERSION REG_G CDS_GROUP_PCD EPICS_SITE_TOP BASE_MODULE_PATH ASYN_MODULE_PATH AUTOSAVE_MODULE_PATH CAPUTLOG_MODULE_PATH CALC_MODULE_PATH ETHERCATMC_MODULE_PATH IOCADMIN_MODULE_PATH MOTOR_MODULE_PATH SSCAN_MODULE_PATH SEQ_MODULE_PATH IOC_PATH IOC_COMMON_PATH
export EPICS_BASE="$BASE_MODULE_PATH" EPICS_HOST_ARCH="freebsd-x86_64" EPICS_SETUP="$CDS_GROUP_PCD/setup" EPICS_CA_REPEATER_PORT="5065" EPICS_PVA_SERVER_PORT="5075" EPICS_PVA_AUTO_ADDR_LIST="YES" EPICS_CA_AUTO_ADDR_LIST="YES" EPICS_PVA_BROADCAST_PORT="5076" EPICS_CA_BEACON_PERIOD="15.0" EPICS_CA_CONN_TMO="30.0" EPICS_CA_MAX_SEARCH_PERIOD="300" EPICS_MODULES="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules" EPICS_CA_MAX_ARRAY_BYTES="40000000" EPICS_CA_SERVER_PORT="5064"

# create directories structure like pcds env
mkdir -p "$REG_G" && ln -sf "$CDS_GROUP_PCD/group/pcds" "$REG_G/pcds"
mkdir -p $EPICS_DEPS


# Clone specific versions of required modules
GIT_MODULE_TOP="https://github.com/slac-epics"
GIT_BASE_TOP="$GIT_MODULE_TOP"

git config --global advice.detachedHead false

git clone  --depth 1 --branch "$BASE_MODULE_TAG" -- "$GIT_BASE_TOP/epics-base.git" "$BASE_MODULE_PATH"
git clone  --depth 1 --branch "$ASYN_MODULE_VERSION" -- "$GIT_MODULE_TOP/asyn.git" "$ASYN_MODULE_PATH"
git clone  --depth 1 --branch "$CALC_MODULE_VERSION" -- "$GIT_MODULE_TOP/calc.git" "$CALC_MODULE_PATH"
git clone  --depth 1 --branch "$IOCADMIN_MODULE_VERSION" -- "$GIT_MODULE_TOP/iocAdmin.git" "$IOCADMIN_MODULE_PATH"
git clone  --depth 1 --branch "$AUTOSAVE_MODULE_VERSION" -- "$GIT_MODULE_TOP/autosave.git" "$AUTOSAVE_MODULE_PATH"
git clone  --depth 1 --branch "$MOTOR_MODULE_VERSION" -- "$GIT_MODULE_TOP/motor.git" "$MOTOR_MODULE_PATH"
git clone  --depth 1 --branch "$ETHERCATMC_MODULE_VERSION" -- "$GIT_MODULE_TOP/ethercatmc.git" "$ETHERCATMC_MODULE_PATH"
git clone  --depth 1 --branch "$SSCAN_MODULE_VERSION" -- "$GIT_MODULE_TOP/sscan.git" "$SSCAN_MODULE_PATH"
git clone  --depth 1 --branch "$SEQ_MODULE_VERSION" -- "$GIT_MODULE_TOP/seq.git" "$SEQ_MODULE_PATH"
git clone  --depth 1 --branch "$CAPUTLOG_MODULE_VERSION" -- "$GIT_MODULE_TOP/caPutLog.git" "$CAPUTLOG_MODULE_PATH"


cp files/RELEASE_SITE $EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/RELEASE_SITE

# bug fix:  osdgetexec.c has freebsd-specific bug which is solved in EPICS base 7.0.6 community version 
cp files/osdgetexec.c $BASE_MODULE_PATH/modules/libcom/src/osi/os/freebsd

# bug fix:  osiRpc.h misses freebsd macro
cp files/osiRpc.h $ASYN_MODULE_PATH/asyn/vxi11

sed -i -e 's/^ASYN_MODULE_VERSION.*=.*$/ASYN_MODULE_VERSION = '${ASYN_MODULE_VERSION}/ $MOTOR_MODULE_PATH/configure/RELEASE.local

# EPICS dependencies
# re2c

echo "building re2c ..."
git clone --depth 1 --branch $RE2C_VERSION https://github.com/skvadrik/re2c.git $RE2C
cd $RE2C

autoreconf -i -W all
./configure && make -j$(nproc) && make install
cd $script_path

# Build EPICS base
gmake -j$(nproc) -C "$BASE_MODULE_PATH"

# Build EPICS modules
gmake -C "$SEQ_MODULE_PATH" RE2C=/usr/local/bin/re2c all clean
gmake -C "$AUTOSAVE_MODULE_PATH" all clean
gmake -C "$ASYN_MODULE_PATH" all clean
gmake -C "$SSCAN_MODULE_PATH" all clean
gmake -C "$CALC_MODULE_PATH" all clean
gmake -C "$IOCADMIN_MODULE_PATH" all clean
gmake -C "$MOTOR_MODULE_PATH" all clean
gmake -C "$CAPUTLOG_MODULE_PATH" all clean

# EPICS ADS modules
# # Set last dependencies
ADS_MODULE_VERSION="R2.0.0-0.0.7"
BECKHOFF_ADS_PATH="/afs/slac.stanford.edu/g/cd/swe/git/repos/package/epics/modules/ADS.git"
ADS_MODULE_PATH="$EPICS_SITE_TOP/$BASE_MODULE_VERSION/modules/twincat-ads/$ADS_MODULE_VERSION"
git clone --depth 1 -- "$GIT_MODULE_TOP/ADS.git" "$BECKHOFF_ADS_PATH/"
git clone --recursive "https://github.com/EuropeanSpallationSource/epics-twincat-ads" "$ADS_MODULE_PATH"

cp files/RELEASE $ADS_MODULE_PATH/configure
cp files/RELEASE.local $ADS_MODULE_PATH/configure
# bug fix: wired error occuires with static building, therefore STATIC_BUILD set to NO
cp files/CONFIG_SITE   $ADS_MODULE_PATH/configure
# bug fix: wrap_socket.h misses freebsd macro
cp files/wrap_socket.h $ADS_MODULE_PATH/BeckhoffADS/AdsLib

cd $ADS_MODULE_PATH
gmake  all clean
cd $script_path

sed -i -e 's/^ASYN_MODULE_VERSION.*=.*$/ASYN_MODULE_VERSION = '${ASYN_MODULE_VERSION}/ $ETHERCATMC_MODULE_PATH/configure/RELEASE.local
gmake -C "$ETHERCATMC_MODULE_PATH"

# ADS IOC
ADS_IOC_VERSION="R0.6.1"

ADS_IOC_ROOT="${IOC_COMMON_PATH}/ads-ioc"
ADS_IOC_PATH="${ADS_IOC_ROOT}/${ADS_IOC_VERSION}"

mkdir -p $ADS_IOC_PATH

GIT_IOC_TOP="https://github.com/pcdshub"
git clone --branch "${ADS_IOC_VERSION}" "${GIT_IOC_TOP}/ads-ioc.git" "${ADS_IOC_PATH}"

cp files/RELEASE_SITE $ADS_IOC_PATH
sed -i -e 's/^ASYN_MODULE_VERSION.*=.*$/ASYN_MODULE_VERSION = '${ASYN_MODULE_VERSION}/ $ADS_IOC_PATH/configure/RELEASE
sed -i -e "s/CROSS_COMPILER_TARGET_ARCHS = linux-x86 linux-x86_64//g" $ADS_IOC_PATH/configure/CONFIG_SITE
# Build
gmake -C "${ADS_IOC_PATH}"
