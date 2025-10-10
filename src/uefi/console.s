.include "uefi/defines.inc"

.section .text
    
    # display string on screen using EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    # see: https://uefi.org/specs/UEFI/2.10/12_Protocols_Console_Support.html#efi-simple-text-output-protocol
    # IN: address of null terminated UTF16 string
    .global efi_con_out_str
    efi_con_out_str:

        # align stack to 16 bytes
        subq $8, %rsp

        # move address of EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL structure in register
        # see: https://uefi.org/specs/UEFI/2.10/04_EFI_System_Table.html#efi-system-table-1
        movq efist(%rip), %rcx
        movq 64(%rcx), %rcx

        # move address of output string in correct register
        # see: https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions?view=msvc-170
        movq %rax, %rdx

        # call UEFI service to output string
        # see: https://uefi.org/specs/UEFI/2.10/12_Protocols_Console_Support.html#simple-text-output-protocol
        callmc *8(%rcx)

        # free stack memory
        addq $8, %rsp

        ret

    # display intiger on screen using EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL
    # see: https://uefi.org/specs/UEFI/2.10/12_Protocols_Console_Support.html#efi-simple-text-output-protocol
    # IN: 32 bit intiger
    .global efi_con_out_int
    efi_con_out_int:

        # allocate 160 bytes for string, because 32 bit intiger can have maximum of 10 digits and string should be UTF16, so 10 * 16 = 160
        # also align stack to 16 bytes, so that's +8 bytes
        subq $168, %rsp

        # save intiger
        pushq %rax

        # zero out digit counter
        xor %ecx, %ecx

    # find out digit count in provided intiger
    # loop and count the cycles, until division gives us 0, which means every digit is removed from intiger
    # EAX: intiger, ECX: digit counter
    count_int_digit:

        # incriment digit counter
        # it should be done at start of the loop, because counter starts at 0 but intiger always has at list 1 character
        inc %ecx

        # divide current intiger by 10, this removes last digit from intiger
        xorl %edx, %edx
        movl $10, %ebx
        divl %ebx

        # result 0 of division by 10 means no digits are left in intiger
        # if there is any digits left in intiger, continue counting loop
        cmp %ax, 0
        jne count_int_digit

        # restore intiger
        popq %rax

        # first step of generating string from intiger, null terminate it at the end
        movw $0, (%rsp, %rcx, 2)

    # loop until all digits are written at string, address RSP (memory is already allocated on stack)
    # EAX: intiger, ECX: counter (from digit count to zero)
    write_int_digit:
        
        # decriment digit counter as we process currently last digit
        # we do this at the beggining, because before the first loop iritation, null terminator was added at RSP + COUNTER * 2
        dec %ecx

        # divide current intiger by 10, this gives us (in EDX) and removes last digit from intiger
        xorl %edx, %edx
        movl $10, %ebx
        divl %ebx

        # character '0' value in UTF16 is 48, so to convert single digit into character, add 48 to it
        # see: https://en.wikipedia.org/wiki/List_of_Unicode_characters
        addw $48, %dx
        movw %dx, (%rsp)
        movw %dx, (%rsp, %rcx, 2)

        # if more than 0 digits are left to process, continue the loop
        cmp %ecx, 0
        jne write_int_digit

        # move address of output string in correct register
        # see: https://learn.microsoft.com/en-us/cpp/build/x64-software-conventions?view=msvc-170
        movq %rsp, %rdx

        # move address of EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL structure in register
        # see: https://uefi.org/specs/UEFI/2.10/04_EFI_System_Table.html#efi-system-table-1
        movq efist(%rip), %rcx
        movq 64(%rcx), %rcx

        # call UEFI service to output string
        # see: https://uefi.org/specs/UEFI/2.10/12_Protocols_Console_Support.html#simple-text-output-protocol
        callmc *8(%rcx)

        # free stack memory
        addq $168, %rsp

        ret
