
###############################################################################
#	Makefile for My Super Sweet 16-Bit M4lw4r3 MS-DOS Edition
#	This Makefile will have targets for using either the nasm or the masm compiler
#	Choose appropriately
#	Viewer discretion is advised
	
#	Each executable is then disassembled using objdump -D and written 
#	a file with filename following the format:
#		dis_$(EXECUTABLE)_$(OPT_LEVEL).txt
#		- where $(EXECUTABLE) is the base name of the executable
#
#	all  		- (default) compile all asm files in directory
# 	clean  		- clean up compiled executable files
#	
#
#
###############################################################################

COM_EXECUTABLES = sweet.com vga_tetris.com

SOURCE_FILES = sweet.asm vga_tetris.asm


SRC_DIR_VGA_TETRIS = $(addprefix vga_tetris/,vga_tetris.asm)
SRC_DIRS =  $(SRC_DIR_VGA_TETRIS) 
DST_DIRS = vga_tetris/ sweet/ 
DST_DIR_VGA_TETRIS = vga_tetris/


NASM = nasm

FLAGS= -f bin

DIS= xxd

DFLAGS= -D


###############################################################################
#
#	Compiling .asm files to .com executables
#
###############################################################################

all: $(EXECUTABLES)


###############################################################################


clean:
	rm -f sweet.com vga_tetris.com

###############################################################################


all:
	$(COM_EXECUTABLES)


sweet.com: sweet.asm
	$(NASM) $(FLAGS) -o $@ $^ 

vga_tetris.com: vga_tetris.asm
	$(NASM) $(FLAGS) -o $@ $^

#vga_tetris.com: vga_tetris/vga_tetris.asm
#	$(NASM) $(FLAGS) -o $(addprefix $(filter $(<D), $(DST_DIRS)), $@) $^



###############################################################################

echo:
	echo "$(SRC_DIRS)"
	echo "$(DST_DIRS)"


###############################################################################
