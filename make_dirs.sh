#!/bin/bash

_base_dir=$PWD
echo "$_base_dir"
_source_files=$(find $_base_dir -type f -name '*.asm')
#echo "$_source_files"

for f in $_source_files; do
	echo "$f"
	dirname=$(basename $f .asm)
	echo "$dirname"
	filename="${f##*/}"
	echo "$(basename ${f})"
	if [ ! -e "$dirname" ]
	then
		echo "subdirectory does not exist:";
		echo "$dirname/$filename";
		mkdir $dirname && cp $filename $dirname;
		continue
	fi
	filename="${f##*/}"
	echo "$(basename ${f})"
	echo "$filname"
done
