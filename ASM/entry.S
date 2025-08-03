.include "ASM/memmap.S"

.syntax unified
.cpu cortex-m33
.thumb

.global _entry
.type _entry, %function
.section .text._entry,"ax",%progbits
_entry:
//PUSH {R0-R4, LR}

////////////////// GPIO25 LED OUTPUT CONFIGURATION /////////////////////

ADDR IO_BANK0_BASE GPIO25_CTRL
MOVVALUE 0x05

ADDR PADS_BANK0_BASE GPIO25
MOVVALUE 0x34

// GPIO_OE_SET  atomic write to set gpio direction as output
// GPIO_OE_CLR -> atomic write to set gpio direction an input

ADDR SIO_BASE GPIO_OE_SET
ATOMICSET 25 1

ADDR SIO_BASE GPIO_OUT_SET
ATOMICSET 25 1

/////////////////// GPIO 17 CS ////////////////////////////

ADDR IO_BANK0_BASE GPIO17_CTRL
CLEARVALUE 0 0x1F
SETVALUE 0 0x05

ADDR SIO_BASE GPIO_OE_SET
ATOMICSET 17 1

ADDR SIO_BASE GPIO_OUT_SET
ATOMICSET 17 1

ADDR PADS_BANK0_BASE GPIO17
CLEARVALUE 8 0x01

//POP {R0-R4, LR}
BX	LR

