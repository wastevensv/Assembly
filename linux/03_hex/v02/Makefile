TARGET=hex
SRC=$(TARGET).asm
OBJ=$(TARGET).o

all: $(OBJ)
	ld -s -m elf_i386 -o $(TARGET) $(OBJ)

debug: $(OBJ)
	ld -ggdb -m elf_i386 -o $(TARGET) $(OBJ)

clean:
	rm $(TARGET) $(OBJ)

$(OBJ): $(SRC)
	nasm -g -f elf -o $(OBJ) $(SRC)
