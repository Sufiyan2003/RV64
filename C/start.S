/* start.S - RV64IM bare-metal reset handler
 * Sets up stack, zeroes .bss, copies .data if needed, jumps to main.
 */

.section .text.start
.global _start

_start:
    /* Set up stack pointer */
    la      sp, _stack_top

    /* Zero out .bss */
    la      t0, _bss_start
    la      t1, _bss_end
bss_clear_loop:
    bge     t0, t1, bss_clear_done
    sd      zero, 0(t0)
    addi    t0, t0, 8
    j       bss_clear_loop
bss_clear_done:

    /* Call main */
    call    main

    /* If main returns, loop forever */
hang:
    j       hang

.size _start, . - _start