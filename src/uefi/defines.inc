
# wrapper of CALL instruction for calls that follow Microsoft x64 ABI conventions.
.macro callmc action
    # store nonvolatile registers that are volatile in Microsoft x64 ABI
    pushq %r10
    pushq %r11
    
    # call provided label
    call \action

    # restore nonvolatile registers
    popq %r11
    popq %r10
.endm
