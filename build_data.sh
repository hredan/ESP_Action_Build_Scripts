#!/bin/bash
TOOL_DIR="./tools"
# https://github.com/earlephilhower/mklittlefs
MKLITTLEFS_VERSION="3.0.0"
MKLITTLEFS_HASH="295fe9b"
# https://github.com/earlephilhower/mklittlefs/releases/download/4.0.2/x86_64-linux-gnu-mklittlefs-db0513a.tar.gz
# TOOL_URL="https://github.com/earlephilhower/mklittlefs/releases/download/$MKLITTLEFS_VERSION/x86_64-linux-gnu-mklittlefs-db0513a.tar.gz"
TOOL=./tools/mklittlefs/mklittlefs
DATA_DIR=./data

HELP="Paramter:\n
-c\tCORE=esp8266/esp32 (mandatory)!\n
-s\tSketch name (mandatory)!\n
e.g. sh ./build_data.sh -s SKETCH_NAME -c esp32\n"

while getopts c:s:h: flag
do
    case "${flag}" in
        c) CORE=${OPTARG};;      
		s) SKETCH_NAME=${OPTARG};;		
		h) echo -e $HELP;;
    esac
done

if [ -z ${SKETCH_NAME} ] || [ -z ${CORE} ]
	then
		echo "ERROR: Sketch name or Core are not defined"
		echo -e $HELP
		exit 1
	else
		echo "### Build data starts with parameter: ###"
		echo -e "Sketch:\t$SKETCH_NAME"
		echo -e "Core:\t$CORE"
fi

if [ -d "$DATA_DIR" ]; then
	#check tool dir#
	if [ ! -d "$TOOL_DIR" ]
		then
			echo "create $TOOL_DIR"
			mkdir $TOOL_DIR
	fi

	if [ ! -f "$TOOL" ]; then
			echo "download and unpack mklittlefs"
			cd "$TOOL_DIR"

			case $OSTYPE in
				linux-gnu)
					ARCHIVE_NAME="x86_64-linux-gnu-mklittlefs-$MKLITTLEFS_HASH.tar.gz"
					TOOL_URL="https://github.com/earlephilhower/mklittlefs/releases/download/$MKLITTLEFS_VERSION/$ARCHIVE_NAME"
					TOOL=./tools/mklittlefs/mklittlefs
					curl -fkLSs $TOOL_URL -o $ARCHIVE_NAME
					retVal=$?
					if [ $retVal -ne 0 ]; then
						echo "curl Error"
						exit $retVal
					fi
					tar -xf ./$ARCHIVE_NAME
					;;
				msys)
					ARCHIVE_NAME="x86_64-w64-mingw32-mklittlefs-$MKLITTLEFS_HASH.zip"
					TOOL_URL="https://github.com/earlephilhower/mklittlefs/releases/download/$MKLITTLEFS_VERSION/$ARCHIVE_NAME"
					TOOL=./tools/mklittlefs/mklittlefs
					curl -fkLSs $TOOL_URL -o $ARCHIVE_NAME
					retVal=$?
					if [ $retVal -ne 0 ]; then
						echo "curl Error"
						exit $retVal
					fi
					unzip ./$ARCHIVE_NAME
					;;
				*)
					echo "OS: $OSTYPE currently not supported!"
					exit 1
					;;
			esac
			cd ..
	fi
	mkdir ./BIN_DATA

	if [ $CORE = "esp32" ]; then
		$TOOL -c ./data -p 256 -b 4096 -s 1441792 ./BIN_DATA/esp32_${SKETCH_NAME}_littlefs.bin
	else
		$TOOL -c ./data -p 256 -b 8192 -s 2072576 ./BIN_DATA/esp8266_${SKETCH_NAME}_littlefs.bin		
	fi
	
	if [ "$?" -ne "0" ]; then
		echo "Creation of littlefs failed"
		exit 1
	fi
else
	echo "No $DATA_DIR available, skip creation of littlefs binaries!"
fi