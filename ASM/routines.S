.syntax unified
.thumb
.global hard_assert
.type hard_assert, %function

hard_assert:
    b .



.thumb
.global busy_wait_at_least_cycles
.type busy_wait_at_least_cycles, %function

// void busy_wait_at_least_cycles(uint32_t minimum_cycles)
busy_wait_at_least_cycles:
    // R0 contient minimum_cycles (1er argument selon l'ABI ARM)
1:
    SUBS R0, R0, #3      // Chaque itération prend environ 3 cycles
    BCS 1b               // Si carry (i.e. R0 >= 0), boucler
    BX LR                // Retour
