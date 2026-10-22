.section .text.boot

.global _start

_start:
    // set stack pointer
    adr x0, __stack_top
    mov sp, x0

_bss_set_zero:
    adr x0, __bss_start
    adr x1, __bss_end
    mov w2, #0
    b _bss_set_zero_check

_bss_set_zero_set:
    strb w2, [x0]       // set byte to zero
    add x0, x0, #1      // increment address

_bss_set_zero_check:
    cmp x0, x1
    b.lo _bss_set_zero_set


_cstart:
    bl cstart

halt:
    // we should never get here because the kernel has its own loop
    b halt
