.include "ASM/memmap.S"
.cpu cortex-m33
.syntax unified
.thumb

.section .text._write,"ax",%progbits
.type _write, %function
.global _write
_write:

	MOV	R0, #0
loop:
	CMP	R0, R2
	IT	EQ
	BXEQ	LR
1:
	ADDR UART0_BASE UARTFR
	LDR     R4, =Base
	LDR     R3, [R4]
        TST     R3, #(1<<5)
        BNE     1b
	LDRB	R3, [R1], #1
	ADDR UART0_BASE UARTDR
	LDR     R4, =Base
	STRB    R3, [R4]
	ADD	R0, R0, #1
	B	loop

.size _write, .-_write


.section .text._clksys, "ax",%progbits
.type _clksys, %function
.global _clksys

_clksys:

////////////////////////////// CLK SYS CONFIGURATION /////////////////////////////////////////

        ADDR    CLOCKS_BASE CLK_SYS_CTRL
//        CLEARVALUE 0 0x1
        SETVALUE   5 0x3
        SETVALUE   0 0x1

        ADDR    CLOCKS_BASE CLK_SYS_DIV
        SETVALUE   16 0xFF

        ADDR    CLOCKS_BASE CLK_PERI_CTRL
        SETVALUE 11 0x1

        ADDR    CLOCKS_BASE CLK_PERI_CTRL
1:
        LDR     R1, =Base
        LDR     R1, [R1]
        TST     R1, #(1 << 28)
        BEQ     1b

	BX	LR
//////////////////////////////////////////////////////////////////////////////////////////////

.size _clksys, .-_clksys


.section .text._uart,"ax",%progbits
.type _uart, %function
.global _uart
_uart:
	PUSH {R0-R4}
///////////////////////////// XOSC CONFIGURATION //////////////////////////////////////////

        // 1. Initialisation XOSC (1-15MHz) -> freq range & enable: 0xAA0 & 0xFAB

    	LDR R0, =XOSC_BASE
    	LDR R1, =XOSC_CTRL_VALUE
    	STR R1, [R0]

.wait_xosc:
    	LDR     R1, [R0, #X0SC_STATUS_REG]         // STATUS
    	TST     R1, #(1 << 31)
    	BEQ     .wait_xosc

	// XOSC src for peri
	ADDR    CLOCKS_BASE CLK_PERI_CTRL
	SETVALUE 5 0x4
	SETVALUE 11 0x1

	ADDR	CLOCKS_BASE CLK_PERI_CTRL
1:
	LDR	R1, =Base
    	LDR     R1, [R1]
    	TST	R1, #(1 << 28)
    	BEQ	1b

//////////////////////////////////////////////////////////////////////////////////////////////    

	// DEASSERT RESET
	ADDR RESETS_BASE NULL
	SETVALUE 26 0x1
	CLEARVALUE 26 0x1

	LDR R0, =RESETS_BASE
        2:
        LDR R1, [r0, #RESET_DONE]
        TST R1, #(1 << 26)
        BEQ 2b

        // Configuration UART0
        LDR R0, =UART0_BASE             // UART0_BASE
        MOV R1, #0
        STR R1, [R0, #UARTCR]           // UARTCR = 0, désactive UART

	MOV R1, #6
        STR R1, [R0, #UARTIBRD]         // UARTIBRD

	MOV R1, #33
        STR R1, [R0, #UARTFBRD]         // UARTFBRD

        // Format : 8 bits, FIFO enable
        MOV R1, #(3 << 5 | 1 << 4)  	// WLEN=8, FIFO enable
        STR R1, [R0, #UARTLCR_H]        // UARTLCR_H

        // Enable UART, TX & RX
        MOV R1, #(1 << 0 | 1 << 8 | 1 << 9)
        STR R1, [R0, #UARTCR]         	// UARTCR

	// IO_BANK0 GPIO/1_CTRL: set FUNCSEL
	ADDR IO_BANK0_BASE GPIO0_CTRL
	CLEARVALUE 0 0x1F		// which is by the way the reset value...
	SETVALUE 0 0x02

	ADDR IO_BANK0_BASE GPIO1_CTRL
        CLEARVALUE 0 0x1F       	// which is by the way the reset value...
        SETVALUE 0 0x02

	 // Set PADS_BANK0 GPIO0/GPIO1: ISO = 0
        ADDR PADS_BANK0_BASE GPIO0
        CLEARVALUE 8 0x1

        ADDR PADS_BANK0_BASE GPIO1
        CLEARVALUE 8 0x1

	POP {R0-R4}
	BX      LR
.size _uart, .-_uart



.section .text._spi, "ax",%progbits
.type _spi, %function
.global _spi

_spi:

	ADDR RESETS_BASE NULL
	SETVALUE 18 0x1
        CLEARVALUE 18 0x1

	LDR R0, =RESETS_BASE
        1:
        LDR R1, [r0, #RESET_DONE]
        TST R1, #(1 << 18)
        BEQ 1b

	ADDR SPI0_BASE SSPCR1
	CLEARVALUE 1 0x1
	CLEARVALUE 2 0x1

	ADDR SPI0_BASE SSPCR0
	SETVALUE 0 0x7
//	CLEARVALUE 4 0x3
//	SETVALUE 8 0x5

	ADDR SPI0_BASE SSPCR1
        SETVALUE 1 0x1

	ADDR IO_BANK0_BASE GPIO16_CTRL
	CLEARVALUE 0 0x1F
	SETVALUE 0 0x01

	ADDR IO_BANK0_BASE GPIO18_CTRL
	CLEARVALUE 0 0x1F
	SETVALUE 0 0x01

	ADDR IO_BANK0_BASE GPIO19_CTRL
	CLEARVALUE 0 0x1F
        SETVALUE 0 0x01

	ADDR PADS_BANK0_BASE GPIO16
	SETVALUE 6 0x01
	CLEARVALUE 8 0x01

	ADDR PADS_BANK0_BASE GPIO18
	SETVALUE 6 0x01
	CLEARVALUE 8 0x01

	ADDR PADS_BANK0_BASE GPIO19
	SETVALUE 6 0x01
	CLEARVALUE 8 0x01

	BX 	LR
.size _spi, .-_spi


.section .text._read_spi_byte,"ax",%progbits
.type _read_spi_byte, %function
.global _read_spi_byte

_read_spi_byte:

0:
        ADDR 	SPI0_BASE NULL
	LDR	R3, =Base
        LDR     R2, [R3, #SSPSR]
        ANDS    R2, #( 1 << 1 )
        BEQ     0b
	# transmit dummy byte
        MOV     R0, #0xFF
        STRB    R0, [R3, #SSPDR]


1:
        ADDR    SPI0_BASE NULL
	LDR	R3, =Base
        LDR     R2, [R3, #SSPSR]
        ANDS    R2, #( 1 << 2 )
        BEQ     1b
	LDRB    R2, [R3, #SSPDR]

        MOV     R0, R2

        BX      LR

.size _read_spi_byte, .-_read_spi_byte


.section .text._write_spi_byte,"ax",%progbits
.type _write_spi_byte, %function
.global _write_spi_byte

_write_spi_byte:

0:
        ADDR    SPI0_BASE NULL
	LDR	R3, =Base
        LDR     R2, [R3, #SSPSR]
        ANDS    R2, #( 1 << 1 )
        BEQ     0b
	STRB    R0, [R3, #SSPDR]

1:
        ADDR SPI0_BASE NULL
	LDR	R3, =Base
        LDR     R2, [R3, #SSPSR]
        ANDS    R2, #( 1 << 2 )
        BEQ     1b
	 # dummy receive
        LDRB    R2, [R3, #SSPDR]

        BX      LR

.size _write_spi_byte, .-_write_spi_byte


.section .text._read_spi_reg,"ax",%progbits
.type _read_spi_reg, %function
.global _read_spi_reg

_read_spi_reg:
	PUSH	{LR}
        BL      hal_pin_nss_low
        BIC     R0, R0, #(1 << 7)
        BL      _write_spi_byte
        BL      _read_spi_byte
        BL      hal_pin_nss_high
	POP	{LR}
        BX	LR

.size _read_spi_reg, .-_read_spi_reg


.section .text._write_spi_reg,"ax",%progbits
.type _write_spi_reg, %function
.global _write_spi_reg

_write_spi_reg:
        PUSH    {LR}
        BL      hal_pin_nss_low
        ORR     R0, R0, #(1 << 7)
        BL      _write_spi_byte
        MOV     R0, R1
        BL      _write_spi_byte
        BL      hal_pin_nss_high
        POP     {LR}
        BX      LR

.size _write_spi_reg, .-_write_spi_reg


.section .text.hal_pin_nss_high,"ax",%progbits
.type hal_pin_nss_high, %function
.global hal_pin_nss_high

hal_pin_nss_high:
        ADDR SIO_BASE GPIO_OUT_SET
        ATOMICSET 17 1
	BX	LR

.size hal_pin_nss_high, .-hal_pin_nss_high


.section .text.hal_pin_nss_low,"ax",%progbits
.type hal_pin_nss_low, %function
.global hal_pin_nss_low

hal_pin_nss_low:
        ADDR SIO_BASE GPIO_OUT_CLR
        ATOMICSET 17 1
	BX	LR

.size hal_pin_nss_low, .-hal_pin_nss_low


.section .text.flip_led,"ax",%progbits
.type flip_led, %function
.global flip_led

flip_led:
        ADDR SIO_BASE GPIO_OUT_XOR
        ATOMICSET 25 1
        BX      LR

.size flip_led, .-flip_led


.section .text.isr_systick,"ax",%progbits
.global isr_systick
.type isr_systick, %function

isr_systick:

	PUSH	{LR}
        LDR     R3, =system_millis
        LDR     R2, [R3]
        ADD     R2, #1
        STR     R2, [R3]
	POP	{LR}

	BX LR

.size , .-isr_systick

.section .text.delay_ms,"ax",%progbits
.type delay_ms, %function
.global delay_ms

delay_ms:
	.comm   next,4
        LDR     R1, =system_millis
        LDR     R1, [R1]
        LDR     R2, =next
        LDR     R2, [R2]
        ADD     R2, R1, R0

1:
        LDR     R1, =system_millis
        LDR     R1, [R1]
        CMP     R2, R1
        WFI
        BGE     1b

        BX      LR

.size delay_ms, .-delay_ms


.section .bss
.global system_millis
.comm system_millis, 4

.global _systick
.type _systick, %function
.section .text._systick,"ax",%progbits

_systick:

	ADDR SYSTICK_BASE LOAD
	LDR	R3, =Base
	#if defined (SYSTICK_150MHZ)
	 ldr	 r2, =150000
	#elif defined (SYSTICK_80MHZ)
         ldr     r2, =80000
	#elif defined (SYSTICK_64MHZ)
	 ldr	 r2, =64000
	#elif defined (SYSTICK_32MHZ)
	 ldr	 r2, =32000
	#elif defined (SYSTICK_16MHZ)
	 ldr	 r2, =16000
	#elif defined (SYSTICK_12MHZ)
         ldr     r2, =12000
	#elif defined (SYSTICK_8MHZ)
	 ldr	 r2, =8000
	#elif defined (SYSTICK_4MHZ)
	 ldr	 r2, =4000
	#elif defined (SYSTICK_2MHZ)
	 ldr	 r2, =2000
	#elif defined (SYSTICK_408KHZ)
         ldr     r2, =408
	#elif defined (SYSTICK_250KHZ)
	 ldr	 r2, =250
	#elif defined (SYSTICK_200KHZ)
	 ldr	 r2, =200
	#elif defined (SYSTICK_125KHZ)
	 ldr	 r2, =125
	#elif defined (_100KHZ)
	 ldr	 r2, =100
	#endif
        str     r2, [r3]

	ADDR SYSTICK_BASE VAL
	LDR     R3, =Base
	LDR	R2, =0
	STR	R2, [R3]

	ADDR SYSTICK_BASE CTRL
	SETVALUE 2 0x01
	SETVALUE 1 0x01
	SETVALUE 0 0x01

	BX LR
.size _systick, .-_systick

