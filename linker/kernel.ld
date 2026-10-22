ENTRY(_start)

STACK_SIZE = 4096;

SECTIONS {
    . = 0x80000;

    .text : {
        KEEP(*(.text.boot))
        *(.text*)
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

   .bss : {
        __bss_start = .;
        *(.bss*)
        __bss_end = .;
    }

    .stack ALIGN(16) : {
        __stack_bottom = .;
        . += STACK_SIZE;
        __stack_top = .;
    }
}
