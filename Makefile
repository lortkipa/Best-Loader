
# project
NAME := BestLoader
BIN := bin
SRC := src

# assembler
ASFILES := $(shell find $(SRC) -name '*.s')
INCFILES := $(shell find $(SRC) -name '*.inc')
AS := as
ASFLAGS := --64 --fatal-warnings -Isrc
ENTRY := main

# linker
OFILES := $(ASFILES:$(SRC)/%.s=$(BIN)/%.o)
LD := ld
LDFLAGS := -nostdlib -m i386pep --oformat pei-x86-64 --subsystem 10 --image-base 0 --enable-reloc-section -e$(ENTRY)

# virtual machine
OVMF := /usr/share/ovmf/x64/OVMF.4m.fd
RAM := 4096
VM := qemu-system-x86_64
VMFLAGS := -m $(RAM) -cpu qemu64 -bios $(OVMF)

run: $(BIN)/$(NAME).img
	@$(VM) $(VMFLAGS) -drive format=raw,file=$<

$(BIN)/$(NAME).img: $(BIN)/$(NAME).efi
	@dd if=/dev/zero of=$@ bs=512 count=93750
	@parted $@ -s -a minimal mklabel gpt
	@parted $@ -s -a minimal mkpart EFI FAT16 2048s 93716s
	@parted $@ -s -a minimal toggle 1 boot
	@mformat -i $@ -h 32 -t 32 -n 64 -c 1
	@mmd -i $@ ::/EFI
	@mmd -i $@ ::/EFI/BOOT
	@mcopy -i $@ $< ::/EFI/BOOT/BOOTx64.EFI
	@echo '   ==> File Created: $@'

$(BIN)/$(NAME).efi: $(OFILES)
	@$(LD) $(LDFLAGS) $^ -o $@
	@echo '   ==> File Created: $@'

# compile .s files into .o
$(BIN)/%.o: $(SRC)/%.s $(INCFILES) $(BIN)
	@mkdir -p $(dir $@)
	@$(AS) $(ASFLAGS) $< -o $@
	@echo '   ==> File Created: $@'

# create binaries folder
$(BIN):
	@mkdir -p $@
	@echo '   ==> Folder Created: $@'

# destroy binaries folder
clean:
	@rm -rf $(BIN)
	@echo '   ==> Folder Destroyed: $@'
