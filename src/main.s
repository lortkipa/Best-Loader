.section .rdata

    msg: .string16 "Hello To BestLoader\n\r"

.section .bss
    
    # UEFI structure, where it's services (function pointers) are provided
    # see: https://uefi.org/specs/UEFI/2.10/04_EFI_System_Table.html#efi-system-table-1
    .global efist
    efist: .space 8

.section .text
    
    # entry point of UEFI application
    # UEFI boot manager will call this function after loading /EFI/BOOT/BOOTx64.EFI file
    # function is called using Microsoft x64 ABI conventions
    # see: https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions?view=msvc-170
    # IN: image handle, address of UEFI system table
    # OUT: UEFI status code
    .global main
    main:

        # align stack to 16 bytes
        subq $8, %rsp

        # store UEFI data
        movq %rdx, efist(%rip)

        # test print functions
        movl $1234567890, %eax
        call efi_con_out_int

    loop:

        # freeze forever, so control won't be returned to UEFI boot manager
        jmp loop
