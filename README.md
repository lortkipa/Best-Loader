# About the project
BestLoader is part of BestOS, but it can be used for costum kernels too.  
Project is written in assembly language mainly for performance reasons, but also because it uses [BestABI](https://github.com/lortkipa/Best-ABI) conventions, wich wouldn't be possible using existing compilers.  

### Dependencies
* `as`
* `ld`
* `make`

### Requirements
* X86_64 CPU architecture
* UEFI boot

# Progress
The project is actively being developed and continuously improved, with bugs being fixed along the way.

### UI
- [ ] Graphics mode
- [ ] Console mode

### Boot protocols
- [ ] Costum
- [ ] Chainloading
- [ ] Linux
- [ ] Multiboot2

### Loadable formats
- [ ] Costum
- [ ] Elf
- [ ] Efi
