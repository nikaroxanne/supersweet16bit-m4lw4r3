
###############################################################################
#	Makefile for My Super Sweet 16-Bit M4lw4r3 MS-DOS Edition
#	This Makefile will have targets for using either the nasm or the masm compiler
#	Choose appropriately
#	Viewer discretion is advised
	
#	Each executable is then disassembled using objdump -D and written 
#	a file with filename following the format:
#		dis_$(EXECUTABLE)_$(OPT_LEVEL).txt
#		- where $(EXECUTABLE) is the base name of the executable
#		and $(OPT_LEVEL) is the optimization level selected during 
#		compilation
#
#	all  		- (default) compile all asm files in directory
# 	clean  		- clean up compiled executable files
#	
#
#
###############################################################################

COM_EXECUTABLES = sweet vga_tetris 

SOURCE_FILES = sweet.asm vga_tetris.asm


## TODO: There is almost certainly a way to condense the next 10 lines into one (probably with globbing of some variety); to be modfiied;

SRC_DIR_VGA_TETRIS = $(addprefix vga_tetris/,vga_tetris.asm)

SRC_DIRS =  $(SRC_DIR_VGA_TETRIS) 

DST_DIRS = $(DST_DIR_VGA_TETRIS)

DST_DIR_VGA_TETRIS = VGA_Tetris/

#EXEC_DIRS = $(DST_DIRS:.o=)

NASM = nasm

FLAGS= -f bin

DIS= xxd

DFLAGS= -D


###############################################################################
#
#	Compiling from source on ARM v7 architecture
#
###############################################################################

#all: $(EXEC_DIRS)
all: $(EXECUTABLES)


###############################################################################


clean:
	rm -f $(SRC_DIRS) *.o 



#$(NASM) $(FLAGS) -c $< -o $(addprefix $(<D)/,$(@))
##$(NASM) $(FLAGS) -o $(addprefix $(filter $(<D), $(DST_DIRS)), $@) $< 

###############################################################################


all:
	$(NASM) $(FLAGS) -o $(COM_EXECUTABLES)


%.com: $(filter %.asm, $(SRC_DIRS))
	$(NASM) $(FLAGS) $< -o $(addprefix $(filter $(<D), $(DST_DIRS)), $@)

sweet: sweet/sweet.asm
	$(NASM) $(FLAGS) -o $(addprefix $(<D)/, $@) $< 


vga_tetris: vga_tetris/vga_tetris.asm
	$(NASM) $(FLAGS) -o $(addprefix $(<D)/, $@) $< 



###############################################################################

echo:
	echo "$(SRC_DIRS)"
	echo "$(DST_DIRS)"


###############################################################################
