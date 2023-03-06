#!/bin/bash

###############################################################################
#	Compile
#	Compile script for C source files used in ARM Assembly Intro guide
#	Each source file is compiled into ARM Assembly, using gcc, with one of
#	four possible options
#		1. No optimization
#		2. O1 optimization
#		3. O2 optimization
#		4. O3 optimization
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

ASSEMBLY_EXT=".asm"
OPT_S_EXTS=("$ASSEMBLY_EXT" "$O1_EXTENSION" "$O2_EXTENSION" "$O3_EXTENSION")

EXEC_EXT=".com"
OPT_EXTS=("$EXEC_EXT" "$O1_EXEC_EXTENSION" "$O2_EXEC_EXTENSION" "$O3_EXEC_EXTENSION")


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
	0) set *.c ;;
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
	
set *.c


for cfile
do
	if [ $COMPILATION_PHASE -eq "2" ]; then
		ASSEMBLY_FILE=${cfile%$C_EXT}$ASSEMBLY_EXT
		$NASM $FLAGS $O_DEFAULT_FLAG $ASSEMBLY_FLAG $cfile -o $ASSEMBLY_FILE
		echo "original filename: $cfile"
		echo "output assembly file filename: $ASSEMBLY_FILE"
	fi

	O0_OBJ_FILE=${cfile%$C_EXT}$OBJ_EXT
	$NASM $FLAGS $O_DEFAULT_FLAG -c $cfile -o $O0_OBJ_FILE
	echo "original filename: $cfile"
	
	for index in `seq 1 "$OPT_RANGE"`
	do
		if [ $COMPILATION_PHASE -eq 2 ]; then
			ASSEMBLY_FILE=${cfile%$C_EXT}$ASSEMBLY_EXT
			$NASM $FLAGS $O_DEFAULT_FLAG $ASSEMBLY_FLAG $cfile -o $ASSEMBLY_FILE
			echo "original filename: $cfile"
			echo "output assembly file filename: $ASSEMBLY_FILE"
		fi
		NEW_O_OBJ_FILE=${cfile%$C_EXT}${OPT_OBJ_EXTS[$index]}
		$NASM $FLAGS $O_FLAG -c $cfile -o $NEW_O_OBJ_FILE
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
			NEW_O_EXEC_FILE=${cfile%$C_EXT}${EXEC_EXTS[$index]}
			echo "$NEW_O_EXEC_FILE"
			O_OBJ_FILE=${cfile%$C_EXT}${OPT_OBJ_EXTS[$index]}
			echo "$O_OBJ_FILE"
			$NASM $FLAGS $O_DEFAULT_FLAG -o $NEW_O_EXEC_FILE $O_OBJ_FILE $LIBS
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
