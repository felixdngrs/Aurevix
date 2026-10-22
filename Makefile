# Toolchain
CROSS_COMPILE ?= aarch64-linux-gnu-

# Tools
GCC		:= $(CROSS_COMPILE)gcc
AS		:= $(CROSS_COMPILE)as
LD		:= $(CROSS_COMPILE)ld
OBJCOPY	:= $(CROSS_COMPILE)objcopy
READELF	:= $(CROSS_COMPILE)readelf
OBJDUMP	:= $(CROSS_COMPILE)objdump

XXD		:= xxd

# Directories
SRC_DIR 		:= src
BOOT_SRC_DIR	:= $(SRC_DIR)/boot
KERNEL_SRC_DIR	:= $(SRC_DIR)/kernel

BUILD_DIR 	= build
LINKER_DIR	= linker

# Targets
KERNEL_ELF	= $(BUILD_DIR)/kernel.elf
KERNEL8_IMG	= $(BUILD_DIR)/kernel8.img
START_OBJ	= $(BUILD_DIR)/start.o
KERNEL_OBJ	= $(BUILD_DIR)/kernel.o

# Important files
LINKER_SCRIPT = $(LINKER_DIR)/kernel.ld

# Emulation
QEMU 					:= qemu-system-aarch64
QEMU_MACHINE			:= raspi3b
QEMU_KERNEL				:= $(KERNEL8_IMG)
QEMU_DISPLAY			:= none
QEMU_SERIAL				:= null
QEMU_GDB_PORT			:= tcp::1234
QEMU_GDB_START_WAIT_S	:= 2

GDB						:= gdb-multiarch

NEW_TERMINAL			:= gnome-terminal --

# GCC options
GCC_C_VERSION	:= c2x
GCC_MCPU		:= cortex-a53
GCC_WARNOPTS	:= -Wall -Wextra -Wpedantic	
GCC_OSOPTS		:= -ffreestanding -fno-stack-protector -fno-pie -mgeneral-regs-only
GCC_DBGOPTS		:= -O0 -g
GCC_BUILDOPTS	:= -c
GCC_OPTS		:= $(GCC_WARNOPTS) $(GCC_OSOPTS) $(GCC_DBGOPTS) $(GCC_BUILDOPTS)

all: $(KERNEL8_IMG)

$(BUILD_DIR):
	@mkdir -p $(BUILD_DIR)

$(START_OBJ): $(BOOT_SRC_DIR)/start.S | $(BUILD_DIR)
	$(AS) -g $< -o $@

$(KERNEL_OBJ): $(KERNEL_SRC_DIR)/init.c | $(BUILD_DIR)
	$(GCC) -std=$(GCC_C_VERSION) -mcpu=$(GCC_MCPU) $(GCC_OPTS) $< -o $(KERNEL_OBJ)

$(KERNEL_ELF): $(LINKER_SCRIPT) $(START_OBJ) $(KERNEL_OBJ)
	$(LD) -T $(LINKER_SCRIPT) $(KERNEL_OBJ) $(START_OBJ) -o $(KERNEL_ELF)

$(KERNEL8_IMG): $(KERNEL_ELF)
	$(OBJCOPY) -O binary $< $@

clean:
	@rm -rf $(BUILD_DIR)

rebuild:
	@$(MAKE) clean
	@$(MAKE) all

dbg-show:
	$(READELF) -a $(KERNEL_ELF)
	$(XXD) $(KERNEL8_IMG)

qemu-start-dbg:
	$(QEMU) -M $(QEMU_MACHINE) -kernel $(QEMU_KERNEL) -display $(QEMU_DISPLAY) -serial $(QEMU_SERIAL) -S -gdb $(QEMU_GDB_PORT) &
	$(NEW_TERMINAL) $(GDB) $(KERNEL_ELF)

.PHONY: all clean rebuild dbg-show qemu-start-dbg
