#!/bin/bash

###############################################################################
#	Compile
#	Compile script for C source files used in ARM Assembly Intro guide
#
#
#
###############################################################################


###############################################################################
#	Setup
###############################################################################

NASM=nasm
MASM=masm

FLAGS="-f bin"

ASM_EXT=".asm"
OPT_S_EXTS=("$ASSEMBLY_EXT" "$O1_EXTENSION" "$O2_EXTENSION" "$O3_EXTENSION")

COM_EXT=".com"
OPT_EXTS=("$COM_EXT")


###############################################################################
#		Cleanup old COM files before compiling
#
###############################################################################

rm -f *.com


###############################################################################
#
#	Compiling from source to ARM Assembly
#
###############################################################################



OPT_RANGE=0

case $# in 
	0) set *.asm ;;
esac


case $1 in
	0) 
		echo "${OPT_EXTS[0]}"
		;;
	1|2|3)
		let OPT_RANGE=$1
		echo "Opt range is: $OPT_RANGE"
		;;
esac	

COMPILATION_PHASE=4

##Compilation Phases enum{PREPROCESSING, COMPILATION, ASSEMBLY, LINKING}
##Default value is 4; unless specified by user

link=all

case $2 in
	#2|a|-a|-assemble) 
	2) 
		let COMPILATION_PHASE=$2
		echo "generating assembly files"
		link=none; shift;;
	3)
		let COMPILATION_PHASE=$2
		echo "generating object files"
		link=none; shift;;
esac
	
set *.asm


for asmfile
do
	if [ $COMPILATION_PHASE -eq "2" ]; then
		ASSEMBLY_FILE=${asmfile%$ASM_EXT}$ASSEMBLY_EXT
		$NASM $FLAGS $O_DEFAULT_FLAG $ASSEMBLY_FLAG $asmfile -o $ASSEMBLY_FILE
		echo "original filename: $asmfile"
		echo "output assembly file filename: $ASSEMBLY_FILE"
	fi

	TARGET_COM_FILE=${asmfile%$ASM_EXT}$COM_EXT
	$NASM $FLAGS -o $TARGET_COM_FILE
	echo "original filename: $asmfile"
	
	for index in `seq 1 "$OPT_RANGE"`
	do
		if [ $COMPILATION_PHASE -eq 2 ]; then
			ASSEMBLY_FILE=${asmfile%$ASM_EXT}$ASSEMBLY_EXT
			$NASM $FLAGS $O_DEFAULT_FLAG $ASSEMBLY_FLAG $asmfile -o $ASSEMBLY_FILE
			echo "original filename: $asmfile"
			echo "output assembly file filename: $ASSEMBLY_FILE"
		fi
		NEW_O_OBJ_FILE=${asmfile%$ASM_EXT}${OPT_OBJ_EXTS[$index]}
		$NASM $FLAGS $O_FLAG -c $asmfile -o $NEW_O_OBJ_FILE
	done
done




###############################################################################
#	Linking object files and libraries to create executables
#
###############################################################################

case $compile in
	all|sweet) 
		$NASM $FLAGS $O_DEFAULT_FLAG -o sweet/sweet.com sweet/sweet.asm
		linked=yes;;
esac



case $link in
	all|sum_and_diff) 
		for index in `seq 0 "$OPT_RANGE"`
		do
			NEW_COM_FILE=${asmfile%$ASM_EXT}${EXEASM_EXTS[$index]}
			echo "$NEW_COMFILE"
			O_OBJ_FILE=${asmfile%$ASM_EXT}${OPT_OBJ_EXTS[$index]}
			echo "$O_OBJ_FILE"
			$NASM $FLAGS $O_DEFAULT_FLAG -o $NEW_O_EXEC_FILE $O_OBJ_FILE
			linked=yes
		done
		;;
esac


###############################################################################
#	For each COM executable, generate corresponding hex dump using xxd
#	save xxd output to appropriately named file
#
###############################################################################


for file in *.com
do
	HEXDUMP_FILE="dis_"$file".txt"
	echo "HEXDUMP FILE: $HEXDUMP_FILE"
	xxd $file > $HEXDUMP_FILE
done


###############################################################################
