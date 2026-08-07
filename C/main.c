/* main.c - minimal bare-metal test program for RV64IM core
 * No libc, no OS. Just enough to prove the core boots and executes.
 */

volatile unsigned long *test_addr = (unsigned long *)0x80001000;

int add(int a, int b) {
    return a + b;
}

int main(void) {
    int result = add(2, 2);          /* exercise ALU */
    *test_addr = (unsigned long)result;  /* observable write for waveform check */

    /* Simple infinite loop counter, useful to confirm PC keeps advancing */
    volatile unsigned long counter = 0;
    while (1) {
        counter++;
        if (counter > 1000000) {
            counter = 0;
        }
    }

    return 0; /* never reached */
}