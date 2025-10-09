.include "uefi/defines.inc"

.section .text
    
    # display text on screen using EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL.
    # see: https://uefi.org/specs/UEFI/2.10/12_Protocols_Console_Support.html#efi-simple-text-output-protocol
    # IN: address of null terminated UTF16 string
    .global eficonout
    eficonout:

        # align stack to 16 bytes
        subq $8, %rsp

        # move address of EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL structure in register
        # see: https://uefi.org/specs/UEFI/2.10/04_EFI_System_Table.html#efi-system-table-1
        movq efist(%rip), %rcx
        movq 64(%rcx), %rcx

        # move address of OutputString label in register
        # see: https://uefi.org/specs/UEFI/2.10/12_Protocols_Console_Support.html#simple-text-output-protocol
        movq %rax, %rdx

        # call UEFI service to output string
        callmc *8(%rcx)

        # free stack memory
        addq $8, %rsp

        ret
