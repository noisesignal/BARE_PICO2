
#ifndef NVIC_H
#define NVIC_H

#define PARAM_ASSERTIONS_ENABLED_HARDWARE_IRQ 0
#define _REG_(x)
typedef volatile uint32_t io_rw_32;
#define NUM_IRQS 32

#if defined(__riscv) && PICO_FORBID_ARM_HEADERS_ON_RISCV
#error "Arm header included in a RISC-V build with PICO_FORBID_ARM_HEADERS_ON_RISCV=1"
#endif

typedef struct {
    // (Description copied from array index 0 register M33_NVIC_ISER0 applies similarly to other array indexes)
    _REG_(M33_NVIC_ISER0_OFFSET) // M33_NVIC_ISER0
    // Enables or reads the enabled state of each group of 32 interrupts
    // 0xffffffff [31:0]  SETENA       (0x00000000) For SETENA[m] in NVIC_ISER*n, indicates whether...
    io_rw_32 iser[2];
 
    uint32_t _pad0[30];
 
    // (Description copied from array index 0 register M33_NVIC_ICER0 applies similarly to other array indexes)
    _REG_(M33_NVIC_ICER0_OFFSET) // M33_NVIC_ICER0
    // Clears or reads the enabled state of each group of 32 interrupts
    // 0xffffffff [31:0]  CLRENA       (0x00000000) For CLRENA[m] in NVIC_ICER*n, indicates whether...
    io_rw_32 icer[2];
 
    uint32_t _pad1[30];
 
    // (Description copied from array index 0 register M33_NVIC_ISPR0 applies similarly to other array indexes)
    _REG_(M33_NVIC_ISPR0_OFFSET) // M33_NVIC_ISPR0
    // Enables or reads the pending state of each group of 32 interrupts
    // 0xffffffff [31:0]  SETPEND      (0x00000000) For SETPEND[m] in NVIC_ISPR*n, indicates whether...
    io_rw_32 ispr[2];
 
    uint32_t _pad2[30];
 
    // (Description copied from array index 0 register M33_NVIC_ICPR0 applies similarly to other array indexes)
    _REG_(M33_NVIC_ICPR0_OFFSET) // M33_NVIC_ICPR0
    // Clears or reads the pending state of each group of 32 interrupts
    // 0xffffffff [31:0]  CLRPEND      (0x00000000) For CLRPEND[m] in NVIC_ICPR*n, indicates whether...
    io_rw_32 icpr[2];
 
    uint32_t _pad3[30];
 
    // (Description copied from array index 0 register M33_NVIC_IABR0 applies similarly to other array indexes)
    _REG_(M33_NVIC_IABR0_OFFSET) // M33_NVIC_IABR0
    // For each group of 32 interrupts, shows the active state of each interrupt
    // 0xffffffff [31:0]  ACTIVE       (0x00000000) For ACTIVE[m] in NVIC_IABR*n, indicates the active state...
    io_rw_32 iabr[2];
 
    uint32_t _pad4[30];
 
    // (Description copied from array index 0 register M33_NVIC_ITNS0 applies similarly to other array indexes)
    _REG_(M33_NVIC_ITNS0_OFFSET) // M33_NVIC_ITNS0
    // For each group of 32 interrupts, determines whether each interrupt targets Non-secure or Secure state
    // 0xffffffff [31:0]  ITNS         (0x00000000) For ITNS[m] in NVIC_ITNS*n, `IAAMO the target Security...
    io_rw_32 itns[2];
 
    uint32_t _pad5[30];
 
    // (Description copied from array index 0 register M33_NVIC_IPR0 applies similarly to other array indexes)
    _REG_(M33_NVIC_IPR0_OFFSET) // M33_NVIC_IPR0
    // Sets or reads interrupt priorities
    // 0xf0000000 [31:28] PRI_N3       (0x0) For register NVIC_IPRn, the priority of interrupt number...
    // 0x00f00000 [23:20] PRI_N2       (0x0) For register NVIC_IPRn, the priority of interrupt number...
    // 0x0000f000 [15:12] PRI_N1       (0x0) For register NVIC_IPRn, the priority of interrupt number...
    // 0x000000f0 [7:4]   PRI_N0       (0x0) For register NVIC_IPRn, the priority of interrupt number...
    io_rw_32 ipr[16];
} nvic_hw_t;

#define nvic_hw ((nvic_hw_t *)(PPB_BASE + M33_NVIC_ISER0_OFFSET))
#define nvic_ns_hw ((nvic_hw_t *)(PPB_NONSEC_BASE + M33_NVIC_ISER0_OFFSET))
static_assert(sizeof (nvic_hw_t) == 0x0340, "");


#endif // NVIC_H
