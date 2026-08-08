/* Simple RV64IM bare-metal linker script
 * Single unified memory: 64KB starting at 0x80000000
 * Adjust MEMORY_SIZE / MEMORY_BASE to match your core once known.
 */

MEMORY
{
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 4K
}

ENTRY(_start)

SECTIONS
{
    /* Code + read-only data */
    .text : {
        *(.text.start)   /* our reset handler must go first */
        *(.text*)
        *(.rodata*)
    } > RAM

    /* Initialized data (loaded from image, lives in RAM at runtime) */
    .data : {
        _data_start = .;
        *(.data*)
        _data_end = .;
    } > RAM

    /* Zero-initialized data */
    .bss : {
        _bss_start = .;
        *(.bss*)
        *(COMMON)
        _bss_end = .;
    } > RAM

    /* Stack: place at top of RAM, grows downward */
    . = ORIGIN(RAM) + LENGTH(RAM);
    _stack_top = .;
}
