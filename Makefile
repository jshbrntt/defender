.PHONY: all clean

DIRS=bin
REDLABEL=redlabel

all: clean 

.PHONY: joust
joust:
	@# Build notes from JOUST.DOC
	@# 
	@#	JOUST	DOCUMENTATION (ASSEMBLY)
	@#
	@#	ASSEMBLY CONDITIONS;
	@#	 NEAR THE BEGINNING OF "RAMDEF.SRC" & "SHRAMDEF.SRC" THERE IS A
	@#	 VARIABLE CALLED "DEBUG".
	@#	  IF "DEBUG EQU 0" THEN IT IS ASSUMED TO BE A FINAL ROM VERSION
	@#	  IF "DEBUG EQU 1" THEN IT IS ASSUMED TO BE A DCON DEBUGGING VERSION
	@#				AND FILE "T12.MOT" WILL OVERLAY "ATT.MOT"
	@#				AND PART OF THE ACTIVE GAME "JOUST.MOT"
	@#				(YOU HAVE 15 SECONDS TO GET TO BOOKS OR
	@#				 DIAGNOSTICS OR ELSE THE PROGRAM WILL
	@#				 LEAVE THE H.S.T.D. PAGE AND CRASH).
	@#
	@#	FILES TO ASSEMBLE;
	@#	 JOUSTI.SRC	- IMAGES
	@#	 MESSAGE.SRC	- MESSAGE STRINGS, FONT, MESSAGE ROUTINES
	@#	 TB12.SRC	- GAME UTILITIES
	@#	 JOUST.SRC	- THE GAME OF JOUST
	@#	 ATT.SRC	- THE MARQUE PAGE OF THE ATTRACT MODE
	@#	 SYSTEM.SRC	- BEAM INTERFERENCE/PROCESS/IRQ OVERHEAD
	@#	 T12.SRC	- DIAGNOSTICS & H.S.T.D. BOARDER
	@#
	@#	VARIOUS FILE INCLUDE
	@#	 PHRASE.SRC	- MESSAGES FOR MESSAGE.SRC
	@#	 RAMDEF.SRC	- GENERAL RAM & SYMBOL DEFINITION & GAME VECTORS
	@#	 SHRAMDEF.SRC	- A SHORTENED VERSION OF RAMDEF (BEWARE OF JOUST.SRC)
	@#	 EQU.SRC	- GENERAL SYMBOL I/O EQUATES & VECTORS
	@#	 SHORTEQU.SRC	- A SHORTENED VERSION OF EQU.SRC (BEWARE OF JOUST.SRC)
	@#	 MESSEQU.SRC	- MESSAGE DEFINITIONS
	@#	 MESSEQU2.SRC	- LETTER & TEXT DEFINITIONS (BEWARE OF JOUST.SRC)
	@#
	@#	SOUNDS FOR JOUST
	@#	 JOUSTSND.SRC	- ENTIRE 4K SOUND ROM (6800 PROCESSOR)
	@#	 JOUSTSCK.SRC	- 6809 VERSION OF SOUND CHECK SUM CALCULATOR
	@#
	@#	CHECK SUM CALCULATOR FOR JOUST
	@#	 SUMMER.SRC	- 6809 VERSION TO CALCULATE ALL JOUST CHECK SUMS
	@#
	@#	UTILITIES
	@#	 COMPACT.COM	- VAX DCL METHOD TO COMPACT CLIFF5 GIVEN 1 SCREEN LINE
	@#			  PER-RECORD, ASCII HEX NIBBLES 0, 8-E.
	@#	 DOWNLDS.COM	- DCON DEBUGGING DOWNLOAD OF ALL FILES FOR JOUST
	./asm6809/src/asm6809 -B joust/message.src\
	    -l bin/message.lst -o bin/message.o

defender: 
	# Build notes from info.src ('DR J.' is presumably Eugene Jarvis!):
	#
	# "TO ASSEMBLE THE DEFENDER MESS
	#
	# RASM PHR2,DEFA2,DEFB2,AMODE0;-X (ELSE CREF SYMBOL OVERFLOW)
	# RASM PHR2,SAMEXPA7
	# RASM PHR2,DEFA2,DEFB2
	# TO GET THE DIAGS, CHAIN ALL.CF
	# LOAD IT ALL AND THEN PRAY IT WORKS
	# (NOTE: BEWARE OF ORDER OF LOADING
	#        LOOK OUT FOR THE SELECTED BLOCK SHIT
	#
	# DR J. 1/21/81"

	$(shell mkdir -p $(DIRS))
	#
	# Build amode1 # The equivalent of: RASM PHR2,DEFA2,DEFB2,AMODE0;-X (ELSE CREF SYMBOL OVERFLOW)
	./asm6809/src/asm6809 -B src/phr6.src src/defa7.src src/defb6.src src/amode1.src\
	 		-l bin/defa7-defb6-amode1.lst  -o bin/defa7-defb6-amode1.o
	#
	# Build samexamp
	# The equivalent of: RASM PHR2,SAMEXPA7
	./asm6809/src/asm6809 -B src/phr6.src src/samexap7.src\
	    -l bin/samexap7.lst -o bin/samexap7.o
	#
	# Build defa7 and defb6
	# The equivalent of: RASM PHR2,DEFA2,DEFB2
	./asm6809/src/asm6809 -B src/phr6.src src/defa7.src src/defb6.src\
 			-l bin/defa7-defb6.lst -o bin/defa7-defb6.o
	#
	# Build blk71
	./asm6809/src/asm6809 -B --6309 src/blk71.src -l bin/blk71.lst -o bin/blk71.o
	#
	# Build roms
	./asm6809/src/asm6809 -B src/mess0.src src/romf8.src src/romc0.src src/romc8.src\
	 		-l bin/roms.lst -o bin/roms.o
	#
	# Build sound
	./vasm-mirror/vasm6800_oldstyle -Fbin -ast -unsshift src/vsndrm1.src\
	 		-L bin/vsndrm1.lst -o bin/vsndrm1.o

# Recreate the binaries in the Red Label ROM board from the objects we assembled in
# the 'defender' section above. Store them in the 'redlabel' directory.
#
redlabel: defender
	$(shell mkdir -p $(REDLABEL))
	# defend.1
	./ChainFilesToRom.py redlabel/defend.1 0x800\
		bin/defa7-defb6-amode1.o,0xb001,0x0000,0x0800,"defa7"
	echo "c9eb365411ca8452debe66e7b7657f44  redlabel/defend.1" | md5sum -c
	# defend.2
	./ChainFilesToRom.py redlabel/defend.2 0x1000\
		bin/defa7-defb6-amode1.o,0xc001,0x0000,0x1000,"defa7"
	./PatchROM.py redlabel/defend.2\
	 	0x07c5,'27fc'
	echo "5e85f9851217645508c36cf33762342f  redlabel/defend.2" | md5sum -c
	# defend.3
	./ChainFilesToRom.py redlabel/defend.3 0x1000\
		bin/defa7-defb6-amode1.o,0xd001,0x0000,0x0c60,"defa7"\
		bin/samexap7.o,0x0001,0x0c60,0x02f8,"samexap"\
		bin/defa7-defb6-amode1.o,0xdf59,0x0f58,0x0230,"defa7"
	echo "f20a652ed2f1497fe899c414d15245a8  redlabel/defend.3" | md5sum -c
	# defend.4
	./ChainFilesToRom.py redlabel/defend.4 0x0800\
		bin/defa7-defb6-amode1.o,0xb801,0x0000,0x0800,"defa7"
	echo "a652dd9a550e1d33f55e76ba954f8999  redlabel/defend.4" | md5sum -c
	# defend.6
	./ChainFilesToRom.py redlabel/defend.6 0x0800\
		bin/blk71.o,0x0001,0x0000,0x0772,"blk71"\
		bin/roms.o,0xa779,0x0778,0x0088,"romc0"
	./PatchROM.py redlabel/defend.6\
	 	0x0772,'000000000000'\
	 	0x00de,'afb4'\
	 	0x07f0,'17'
	echo "fadaacee0e506f701ea3e61dfa23c548  redlabel/defend.6" | md5sum -c
	# defend.7
	./ChainFilesToRom.py redlabel/defend.7 0x0800\
		bin/roms.o,0xa001,0x0000,0x0800,"roms"
	echo "5b9d4e0664e01c48560b05d5941ee908  redlabel/defend.7" | md5sum -c
	# defend.8
	./ChainFilesToRom.py redlabel/defend.8 0x0800\
		bin/roms.o,0x0001,0x0000,0x0800,"roms"
	echo "dd4d18f5d3d14ab94f09b05335da3bf4  redlabel/defend.8" | md5sum -c
	# defend.9
	./ChainFilesToRom.py redlabel/defend.9 0x0800\
		bin/defa7-defb6-amode1.o,0x0001,0x0000,0x0800,"defa7"
	echo "3de0cf05f6ee1fd7da6ccaba93fce3fc  redlabel/defend.9" | md5sum -c
	# defend.10
	./ChainFilesToRom.py redlabel/defend.10 0x0800\
		bin/roms.o,0xa801,0x0000,0x0800,"roms"
	./PatchROM.py redlabel/defend.10\
	 	0x07f0,'4a'
	echo "7bd2ddcb4ce8c5ceb8150b61cb2a2335  redlabel/defend.10" | md5sum -c
	# defend.11
	./ChainFilesToRom.py redlabel/defend.11 0x0800\
		bin/roms.o,0x0801,0x0000,0x0800,"roms"\
		src/unknown.bin,0x0001,0x0450,0x0800,"roms"
	echo "0fda70334d594b58cd26ad032be16c4b  redlabel/defend.11" | md5sum -c
	# defend.12
	./ChainFilesToRom.py redlabel/defend.12 0x0800\
		bin/defa7-defb6-amode1.o,0x0801,0x0000,0x0800,"defa7"\
		bin/defa7-defb6-amode1.o,0xaeea,0x06e9,0x0117,"amode tail"
	echo "8115fdb8540e93d38e036f007e19459a  redlabel/defend.12" | md5sum -c
	# defend.snd
	./ChainFilesToRom.py redlabel/defend.snd 0x0800\
		bin/vsndrm1.o,0xf801,0x0000,0x0800,"vsndrm1"
	# This should be 8a, but the assembler used for the ROM has calculated the product
	# of (61857>>1)/3/1*1)*2) as '508b' instead of '508a'. See ORGTAB in vsndrm1.src.
	./PatchROM.py redlabel/defend.snd\
	 	0x05b6,'8b'
	echo "ec5b36f80f7bd93ba9e6269f0376efd6  redlabel/defend.snd" | md5sum -c

defender.zip: redlabel
	zip -r defender.zip redlabel

clean:
	-rm bin/*.o
	-rm bin/*.lst
	-rm defender.rom
	-rm defend*.bin
