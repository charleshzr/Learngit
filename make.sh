#!/bin/bash
CUST=dab-mmi-FS2445-0000-0108
#CUST=p1-fm-iui-mmi.ref.proteus-europa
#CUST=bt-p1-fm-mmi.ref.proteus-venus2ibt
#CUST=dab-fm-iui-mmi.ref.verona2-venus
#CUST=p1-fm-iui-mmi.ref.verona2-venus
VERSION=1A4
MODEL=dab-mmi-FS2445-0000-0108

#NEEDED_VER="2.8.1.0.3.0"

#----------------------------------------------------------------------------------------------------
RELEASE_NOTE_FILENAME=${MODEL}_release_note_$VERSION.txt
SDK_VERSION=`cat core/mak/defaultversion.mak | grep VERSION | cut -d' ' -f3 | tr -d '\r'`
MD5SUM_FILENAME=${CUST}_V${SDK_VERSION}-${VERSION}.txt
ZIP_FILENAME=${CUST}_V${SDK_VERSION}-${VERSION}.zip

VER_RE="[0-9]+.[0-9]+.[0-9]+b[0-9]+[a-z]?"
#export METAG_INST_ROOT=$(echo $METAG_INST_ROOT | sed -r "s/$VER_RE/$NEEDED_VER/")
export METAG_INST_ROOT="/opt/imgtec/metag/2.8.1.0.3.0/"

if [ "$1" == "d" ]; then
BUILD_CMD="make CUSTOM=$CUST BOOT="
else
BUILD_CMD="make CUSTOM=$CUST BOOT=usb VERSION_SUFFIX=-$VERSION BUILD_OPTION_DFU_WIZARD=yes"
#BUILD_CMD="make CUSTOM=$CUST VERSION_SUFFIX=-$VERSION BUILD_OPTION_DFU_WIZARD=yes"
fi

function format_echo {
	echo -e "\033[1;4;33m$1\033[0m = \033[36m${!1}\033[0m"
}

function gen_release_note {
	BUILD_DATE=$(date +"%d %b. %Y")
	echo -en "Release Note:\r\n" > $RELEASE_NOTE_FILENAME
	echo -en "($(ls $CUST*$VERSION.bin))\r\n\r\n" >> $RELEASE_NOTE_FILENAME

	echo -en "Date: $BUILD_DATE\r\n\r\n" >> $RELEASE_NOTE_FILENAME

	echo -en "Change Note:\r\n" >> $RELEASE_NOTE_FILENAME
	echo -en "---------------------------------------------------\r\n\r\n\r\n" >> $RELEASE_NOTE_FILENAME

	echo -en "Known Issue:\r\n" >> $RELEASE_NOTE_FILENAME
	echo -en "---------------------------------------------------\r\n" >> $RELEASE_NOTE_FILENAME
}

function consolidate_release {
	if [ -d $VERSION ]; then 
		rm -rf $VERSION
	fi
	echo "Generating Release [$VERSION]"
	mkdir $VERSION
	cp build/$CUST/$CUST* $VERSION

	cd $VERSION
	md5sum $(ls $CUST*$VERSION.bin) > ${MD5SUM_FILENAME}
	cat ${MD5SUM_FILENAME}
	gen_release_note
	zip ${ZIP_FILENAME} $(ls $CUST*$VERSION.bin) ${MD5SUM_FILENAME}
	cd ..
}

function echo_build_command {
#	echo -e "\033[1;4;36mmake CUSTOM=$CUST VERSION_SUFFIX=-$VERSION BOOT=usb BUILD_OPTION_DFU_WIZARD=yes\033[0m"
	echo -e "\033[1;4;36m$BUILD_CMD\033[0m"
}

format_echo METAG_INST_ROOT
format_echo CUST
format_echo VERSION

cd core
if [ "$1" == "c" ]; then
make clobber
fi
time $BUILD_CMD

cd ..
rm core/apps

if [ -e build/$CUST/$CUST*$VERSION.bin ]; then 
	consolidate_release
fi
date

echo_build_command 

Git is a distributed version control system.
Git is free software.