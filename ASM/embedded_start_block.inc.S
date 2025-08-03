#define BINARY_INFO_MARKER_START 0x7188ebf2
#define BINARY_INFO_MARKER_END 0xe71aa390
#define PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE               _u(0x42)
#define PICOBIN_BLOCK_ITEM_2BS_LAST             (_u(0x80) | _u(0x7f))
#define PICOBIN_BLOCK_MARKER_START _u(0xffffded3)
#define PICOBIN_BLOCK_MARKER_END   _u(0xab123579)
#define BOOTROM_VTABLE_OFFSET 0x00
#define M33_VTOR_OFFSET _u(0x0000ed08)
#define SIO_CPUID_OFFSET _u(0x00000000)



#define _u(x) x


#define _PICOBIN_INDEX_TO_BITS(y, x) (y ## x << y ## _LSB)
#define PICOBIN_INDEX_TO_BITS(y, x) (y ## _ ## x << y ## _LSB)

#define PICOBIN_IMAGE_TYPE_IMAGE_TYPE_LSB            _u(0)
#define PICOBIN_IMAGE_TYPE_IMAGE_TYPE_BITS           _u(0x000f)
#define PICOBIN_IMAGE_TYPE_IMAGE_TYPE_INVALID        _u(0x0)
#define PICOBIN_IMAGE_TYPE_IMAGE_TYPE_EXE            _u(0x1)
#define PICOBIN_IMAGE_TYPE_IMAGE_TYPE_DATA           _u(0x2)
#define PICOBIN_IMAGE_TYPE_IMAGE_TYPE_AS_BITS(x) _PICOBIN_INDEX_TO_BITS(PICOBIN_IMAGE_TYPE_IMAGE_TYPE, _ ## x)

#define PICOBIN_IMAGE_TYPE_EXE_SECURITY_LSB          _u(4)
#define PICOBIN_IMAGE_TYPE_EXE_SECURITY_BITS         _u(0x0030)
#define PICOBIN_IMAGE_TYPE_EXE_SECURITY_UNSPECIFIED  _u(0x0)
#define PICOBIN_IMAGE_TYPE_EXE_SECURITY_NS           _u(0x1)
#define PICOBIN_IMAGE_TYPE_EXE_SECURITY_S            _u(0x2)
#define PICOBIN_IMAGE_TYPE_EXE_SECURITY_AS_BITS(x) _PICOBIN_INDEX_TO_BITS(PICOBIN_IMAGE_TYPE_EXE_SECURITY, _ ## x)

#define PICOBIN_IMAGE_TYPE_EXE_CPU_LSB               _u(8)
#define PICOBIN_IMAGE_TYPE_EXE_CPU_BITS              _u(0x0700)
#define PICOBIN_IMAGE_TYPE_EXE_CPU_ARM               _u(0)
#define PICOBIN_IMAGE_TYPE_EXE_CPU_RISCV             _u(1)
#define PICOBIN_IMAGE_TYPE_EXE_CPU_VARMULET          _u(2)
#define PICOBIN_IMAGE_TYPE_EXE_CPU_AS_BITS(x) _PICOBIN_INDEX_TO_BITS(PICOBIN_IMAGE_TYPE_EXE_CPU, _ ## x)

#define PICOBIN_IMAGE_TYPE_EXE_EXTRA_SECURITY_LSB    _u(11)
#define PICOBIN_IMAGE_TYPE_EXE_EXTRA_SECURITY_BITS   _u(0x0800)

#define PICOBIN_IMAGE_TYPE_EXE_CHIP_LSB              _u(12)
#define PICOBIN_IMAGE_TYPE_EXE_CHIP_BITS             _u(0x7000)
#define PICOBIN_IMAGE_TYPE_EXE_CHIP_RP2040           _u(0)
#define PICOBIN_IMAGE_TYPE_EXE_CHIP_RP2350           _u(1)
#define PICOBIN_IMAGE_TYPE_EXE_CHIP_AS_BITS(x) _PICOBIN_INDEX_TO_BITS(PICOBIN_IMAGE_TYPE_EXE_CHIP, _ ## x)

#define PICOBIN_IMAGE_TYPE_EXE_TBYB_BITS             _u(0x8000)


#if !defined(PICO_CRT0_INCLUDE_PICOBIN_IMAGE_TYPE_ITEM)
// todo decide whether we want this item for RP2040 by default, probably not (there are a zilloon binaries out there without it)
#if !PICO_RP2040
#define PICO_CRT0_INCLUDE_PICOBIN_IMAGE_TYPE_ITEM 1
#endif
#endif

#ifndef PICO_CRT0_INCLUDE_PICOBIN_BLOCK
#define PICO_CRT0_INCLUDE_PICOBIN_BLOCK PICO_CRT0_INCLUDE_PICOBIN_IMAGE_TYPE_ITEM
#endif

#ifndef PICO_CRT0_INCLUDE_PICOBIN_END_BLOCK
#define PICO_CRT0_INCLUDE_PICOBIN_END_BLOCK (PICO_CRT0_INCLUDE_PICOBIN_BLOCK && !PICO_NO_FLASH)
#endif

#if PICO_CRT0_IMAGE_TYPE_TBYB
#define CRT0_TBYB_FLAG PICOBIN_IMAGE_TYPE_EXE_TBYB_BITS
#else
#define CRT0_TBYB_FLAG 0
#endif

#if defined(PICO_CRT0_VERSION_MINOR) && !defined(PICO_CRT0_VERSION_MAJOR)
#define PICO_CRT0_VERSION_MAJOR 0
#endif

#if PICO_CRT0_INCLUDE_PICOBIN_BLOCK
.section .embedded_block, "a"
.p2align 2
embedded_block:
.word PICOBIN_BLOCK_MARKER_START

#if PICO_CRT0_INCLUDE_PICOBIN_IMAGE_TYPE_ITEM
// include an IMAGE_TYPE item at the start so this block is a valid IMAGE_DEF block, and can be used as a basis
// for booting the binary with a known type.
.byte PICOBIN_BLOCK_ITEM_1BS_IMAGE_TYPE
.byte 0x1 // 1 word
#ifdef PICO_CRT0_IMAGE_TYPE_ITEM_VALUE
.hword PICO_CRT0_IMAGE_TYPE_ITEM_VALUE
#elif defined(__riscv)
.hword PICOBIN_IMAGE_TYPE_IMAGE_TYPE_AS_BITS(EXE) | \
       PICOBIN_IMAGE_TYPE_EXE_CPU_AS_BITS(RISCV) | \
       PICOBIN_IMAGE_TYPE_EXE_CHIP_AS_BITS(RP2350) | \
       CRT0_TBYB_FLAG
#elif defined(PICO_RP2040)
.hword PICOBIN_IMAGE_TYPE_IMAGE_TYPE_AS_BITS(EXE) | \
       PICOBIN_IMAGE_TYPE_EXE_SECURITY_AS_BITS(NS) | \
       PICOBIN_IMAGE_TYPE_EXE_CPU_AS_BITS(ARM) | \
       PICOBIN_IMAGE_TYPE_EXE_CHIP_AS_BITS(RP2040) | \
       CRT0_TBYB_FLAG
#else
.hword PICOBIN_IMAGE_TYPE_IMAGE_TYPE_AS_BITS(EXE) | \
       PICOBIN_IMAGE_TYPE_EXE_SECURITY_AS_BITS(S) | \
       PICOBIN_IMAGE_TYPE_EXE_CPU_AS_BITS(ARM) | \
       PICOBIN_IMAGE_TYPE_EXE_CHIP_AS_BITS(RP2350) | \
       CRT0_TBYB_FLAG
#endif
#else
// if no image type, then add ignored item
.byte PICOBIN_BLOCK_ITEM_2BS_IGNORED
.byte 0x1 // 1 word
.hword 0
#endif

#ifdef PICO_CRT0_VERSION_MAJOR
.byte PICOBIN_BLOCK_ITEM_1BS_VERSION
.byte 0x2 // 2 words
.hword 0
#ifdef PICO_CRT0_VERSION_MINOR
.hword PICO_CRT0_VERSION_MINOR
#else
.hword 0
#endif
.hword PICO_CRT0_VERSION_MAJOR
#endif

#ifdef __riscv
// On RISC-V the default entry point from bootrom is the start of the binary, but
// we have our vtable at the start, so we must include an entry point
.byte PICOBIN_BLOCK_ITEM_1BS_ENTRY_POINT
.byte 0x3 // word size to next item
.byte 0 // pad
.byte 0 // pad
.word _reset_handler
.word SRAM_END // stack pointer
#endif

#ifndef PICO_RP2040
#if PICO_NO_FLASH
// If no_flash bin, then include a vector table item
.byte PICOBIN_BLOCK_ITEM_1BS_VECTOR_TABLE
.byte 0x2
.hword 0
.word __vectors
#endif
#endif

.byte PICOBIN_BLOCK_ITEM_2BS_LAST
.hword (embedded_block_end - embedded_block - 16 ) / 4 // total size of all
.byte 0
#if PICO_CRT0_INCLUDE_PICOBIN_END_BLOCK
.word embedded_end_block - embedded_block
#else
// offset from this block to next block in loop (since we are a single block loop, we point back to ourselves
// so the offset is 0)
.word 0
#endif
.word PICOBIN_BLOCK_MARKER_END
embedded_block_end:
#endif
