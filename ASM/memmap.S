.syntax unified
.cpu cortex-m33
.fpu fpv5-sp-d16
.thumb


.macro ADDR bus peripheral
        .set Base, \bus + \peripheral
.endm

.macro SETVALUE shift val                         @;Set bit to 1 of [addr](which is given by addr
        ldr r3, =Base                            @;Move address value into r2: 0x40023830
        ldr r2, [r3]                            @;Load the value of addr into r1
        orr r2, r2, #(\val << \shift)                 @;Set the bit by shifting a 1 to the position
        str r2, [r3]                            @;Store back value
.endm


.macro CLEARVALUE shift val                         @;Set bit to 1 of [addr](which is given by addr
        ldr r3, =Base                            @;Move address value into r2: 0x40023830
        ldr r2, [r3]                            @;Load the value of addr into r1
        bic r2, r2, #(\val << \shift)
        str r2, [r3]                            @;Store back value
.endm

.macro MOVVALUE val
	ldr R3, =Base
	MOV R2, #(\val)
	STR R2, [R3]

.endm

.macro ATOMICSET shift val
	LDR R3, =Base
	MOV R2, #(\val << \shift)
	STR R2, [R3]
.endm


.macro CLEAR_bit ba bo
        ldr r3, =\ba
        ldr r2, [r3]
        bic r2, r2, #(1 << \bo)
        str r2, [r3]
.endm

.equ NULL, 0x00

.equ ROM_BASE, 0x00000000

.equ XIP_BASE, 0x10000000
.equ XIP_SRAM_BASE, 0x13ffc000
.equ XIP_END, 0x14000000
.equ XIP_NOCACHE_NOALLOC_BASE, 0x14000000
.equ XIP_SRAM_END, 0x14000000
.equ XIP_NOCACHE_NOALLOC_END, 0x18000000
.equ XIP_MAINTENANCE_BASE, 0x18000000
.equ XIP_NOCACHE_NOALLOC_NOTRANSLATE_BASE, 0x1c000000

.equ SRAM0_BASE, 0x20000000
.equ XIP_NOCACHE_NOALLOC_NOTRANSLATE_END, 0x20000000
.equ SRAM_BASE, 0x20000000
.equ SRAM_STRIPED_BASE, 0x20000000
.equ SRAM4_BASE, 0x20040000
.equ SRAM8_BASE, 0x20080000
.equ SRAM_STRIPED_END, 0x20080000
.equ SRAM_SCRATCH_X_BASE, 0x20080000
.equ SRAM9_BASE, 0x20081000
.equ SRAM_SCRATCH_Y_BASE, 0x20081000
.equ SRAM_END, 0x20082000

.equ SYSINFO_BASE, 0x40000000
.equ SYSCFG_BASE, 0x40008000
.equ CLOCKS_BASE, 0x40010000
.equ PSM_BASE, 0x40018000
.equ RESETS_BASE, 0x40020000
.equ IO_BANK0_BASE, 0x40028000
.equ IO_QSPI_BASE, 0x40030000
.equ PADS_BANK0_BASE, 0x40038000
.equ PADS_QSPI_BASE, 0x40040000
.equ XOSC_BASE, 0x40048000
.equ PLL_SYS_BASE, 0x40050000
.equ PLL_USB_BASE, 0x40058000
.equ ACCESSCTRL_BASE, 0x40060000
.equ BUSCTRL_BASE, 0x40068000
.equ UART0_BASE, 0x40070000
.equ UART1_BASE, 0x40078000
.equ SPI0_BASE, 0x40080000
.equ SPI1_BASE, 0x40088000
.equ I2C0_BASE, 0x40090000
.equ I2C1_BASE, 0x40098000
.equ ADC_BASE, 0x400a0000
.equ PWM_BASE, 0x400a8000
.equ TIMER0_BASE, 0x400b0000
.equ TIMER1_BASE, 0x400b8000
.equ HSTX_CTRL_BASE, 0x400c0000
.equ XIP_CTRL_BASE, 0x400c8000
.equ XIP_QMI_BASE, 0x400d0000
.equ WATCHDOG_BASE, 0x400d8000
.equ BOOTRAM_BASE, 0x400e0000
.equ BOOTRAM_END, 0x400e0400
.equ ROSC_BASE, 0x400e8000
.equ TRNG_BASE, 0x400f0000
.equ SHA256_BASE, 0x400f8000
.equ POWMAN_BASE, 0x40100000
.equ TICKS_BASE, 0x40108000
.equ OTP_BASE, 0x40120000
.equ OTP_DATA_BASE, 0x40130000
.equ OTP_DATA_RAW_BASE, 0x40134000
.equ OTP_DATA_GUARDED_BASE, 0x40138000
.equ OTP_DATA_RAW_GUARDED_BASE, 0x4013c000
.equ CORESIGHT_PERIPH_BASE, 0x40140000
.equ CORESIGHT_ROMTABLE_BASE, 0x40140000
.equ CORESIGHT_AHB_AP_CORE0_BASE, 0x40142000
.equ CORESIGHT_AHB_AP_CORE1_BASE, 0x40144000
.equ CORESIGHT_TIMESTAMP_GEN_BASE, 0x40146000
.equ CORESIGHT_ATB_FUNNEL_BASE, 0x40147000
.equ CORESIGHT_TPIU_BASE, 0x40148000
.equ CORESIGHT_CTI_BASE, 0x40149000
.equ CORESIGHT_APB_AP_RISCV_BASE, 0x4014a000
.equ DFT_BASE, 0x40150000
.equ GLITCH_DETECTOR_BASE, 0x40158000
.equ TBMAN_BASE, 0x40160000

.equ DMA_BASE, 0x50000000
.equ USBCTRL_BASE, 0x50100000
.equ USBCTRL_DPRAM_BASE, 0x50100000
.equ USBCTRL_REGS_BASE, 0x50110000
.equ PIO0_BASE, 0x50200000
.equ PIO1_BASE, 0x50300000
.equ PIO2_BASE, 0x50400000
.equ XIP_AUX_BASE, 0x50500000
.equ HSTX_FIFO_BASE, 0x50600000
.equ CORESIGHT_TRACE_BASE, 0x50700000

.equ SIO_BASE, 0xd0000000
.equ SIO_NONSEC_BASE, 0xd0020000

.equ PPB_BASE, 0xe0000000
.equ PPB_NONSEC_BASE, 0xe0020000
.equ EPPB_BASE, 0xe0080000


###################### REGISTER DEFINITIONS ####################################


.equ GPIO0_CTRL, 0x004
.equ GPIO1_CTRL, 0x00C

.equ GPIO19_CTRL, 0x09C
.equ GPIO18_CTRL, 0x094
.equ GPIO17_CTRL, 0x08C
.equ GPIO16_CTRL, 0x084

.equ GPIO0, 0x04
.equ GPIO1, 0x08
.equ GPIO2, 0x0C
.equ GPIO3, 0x10
.equ GPIO4, 0x14
.equ GPIO5, 0x18
.equ GPIO6, 0x1C
.equ GPIO7, 0x20
.equ GPIO8, 0x24
.equ GPIO9, 0x28
.equ GPIO10, 0x2C

.equ GPIO16, 0x44
.equ GPIO17, 0x48
.equ GPIO18, 0x4C
.equ GPIO19, 0x50

.equ GPIO25_CTRL, 0x0cc
.equ GPIO25, 0x68
.equ GPIO_OE, 0x030
.equ GPIO_OE_SET, 0x038
.equ GPIO_OE_CLR, 0x040
.equ GPIO_OE_XOR, 0x048
.equ GPIO_OUT, 0x10
.equ GPIO_OUT_SET, 0x018
.equ GPIO_OUT_XOR, 0x028
.equ GPIO_OUT_CLR, 0x020

.equ UARTCR, 0x030
.equ UARTIBRD, 0x024
.equ UARTFBRD, 0x028
.equ UARTDR, 0x000
.equ UARTFR, 0x018
.equ UARTLCR_H, 0x02C

.equ SSPCR0, 0x000
.equ SSPCR1, 0x004
.equ SSPDR, 0x008
.equ SSPSR, 0x00C
.equ SSPCPSR, 0x010


.equ RESET_UART0_BIT, (1 << 22)

.equ CLK_UART0_CTRL,  (0x48)
.equ CLK_UART0_DIV,   (0x4C)


.equ XOSC_CTRL_VALUE, 0x00FABAA0
.equ X0SC_STATUS_REG, 0x04
.equ CLK_PERI_CTRL, 0x48
.equ XOSC_CTRL, 0x00

.equ CLK_SYS_CTRL, 0x3C
.equ CLK_SYS_DIV, 0x40

.equ RESET_DONE, 0x08

.equ M33_NVIC_ISER0_OFFSET, 0x0000e100


.equ SCS_BASE,		0xE000E000UL
.equ ITM_BASE,		0xE0000000UL
.equ DWT_BASE,		0xE0001000UL
.equ TPIU_BASE,		0xE0040000UL
.equ DCB_BASE,		0xE000EDF0UL
.equ DIB_BASE,		0xE000EFB0UL
.equ SYSTICK_BASE, 	SCS_BASE +  0x0010UL
.equ NVIC_BASE, 	SCS_BASE +  0x0100UL
.equ SCB_BASE, 		SCS_BASE +  0x0D00UL

.equ CTRL,		0x00
.equ LOAD,		0x04
.equ VAL,		0x08
.equ CALIB,		0x0C

.equ SYSTICK_CTRL_CLKSOURCE_Msk,		(1 << 2)            /*!< SysTick CTRL: CLKSOURCE Mask */


.equ SYSTICK_CTRL_ENABLE_Msk,			(1 << 0)



.global usb_dpram
.set usb_dpram, USBCTRL_DPRAM_BASE
