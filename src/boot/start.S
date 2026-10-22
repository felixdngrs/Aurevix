.equ CORE_0_ID, 0
.equ CORE_1_ID, 1
.equ CORE_2_ID, 2
.equ CORE_3_ID, 3

.section .text.boot

.global _start

_start:

mrs x0, MPIDR_EL1
and w0, w0, #0xff // we want to read the first byte of this register
// check for core 0
cmp w0, #CORE_0_ID
b.eq core_0
// check for core 1
cmp w0, #CORE_1_ID
b.eq core_1
// check for core 2
cmp w0, #CORE_2_ID
b.eq core_2
// check for core 3
cmp w0, #CORE_3_ID
b.eq core_3
// no core detected
b undefined_core

///////////////// core 0 /////////////////
core_0:
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

///////////////// core 1 /////////////////
core_1:
    wfe // wait for event
    b core_1
///////////////// core 2 /////////////////
core_2:
    wfe // wait for event
    b core_2
///////////////// core 3 /////////////////
core_3:
    wfe // wait for event
    b core_3

undefined_core:
    b undefined_core