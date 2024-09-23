TOOLCHAIN_PREFIX = aarch64-linux-gnu-

CC = $(TOOLCHAIN_PREFIX)gcc
LD = $(TOOLCHAIN_PREFIX)ld

OBJCPY = $(TOOLCHAIN_PREFIX)objcopy
#data path definition
SRC_DIR = src
OUT_DIR = out

LINKER_FILE = $(SRC_DIR)/linker.ld
ENTRY = $(SRC_DIR)/start.s
ENTRY_OBJS = $(SRC_DIR)/start.o
#all .c file
SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(SRCS:$(SRC_DIR)/%.c=$(OUT_DIR)/%.o)

CFLAGS = -Wall -I include -c

.PHONY: all clean run asm debug directories

all: kernel8.img directories

$(ENTRY_OBJS): $(ENTRY)
	$(CC) $(CFLAGS) $< -o $@

$(OUT_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) $< -o $@

kernel8.img: $(OBJS) $(ENTRY_OBJS)
	$(LD) -T $(LINKER_FILE) -o kernel8.elf $(ENTRY_OBJS) $(OBJS)
	$(OBJCPY) -O binary kernel8.elf kernel8.img
run: all
	qemu-system-aarch64 -M raspi3b -kernel kernel8.img -display none -serial null -serial stdio
asm:
	qemu-system-aarch64 -M raspi3b -kernel kernel8.img -display none -d in_asm
debug: all
	qemu-system-aarch64 -M raspi3b -kernel kernel8.img  -display -S -s

directories: $(OUT_DIR)

$(OUT_DIR):
	mkdir -p $(OUT_DIR)
clean:
	rm -f out/* kernel8.*

CFLAGS = -Wall

.PHONY: all clean run

all: kernel8.img clean

main.o:main.s
	$(CC) $(CFLAGS) -c main.s -o main.o

kernel8.img: main.o
	$(LD) -T linker.ld -o kernel8.elf main.o
	$(OBJCPY) -O binary kernel8.elf kernel8.img

clean:
	rm -f *.o

run:
	