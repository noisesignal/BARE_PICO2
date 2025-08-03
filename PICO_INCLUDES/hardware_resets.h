#ifndef __HARDWARE_RESETS_H__
#define __HARDWARE_RESETS_H__


#include "resets.h"

static __force_inline void tight_loop_contents(void) {}

static __force_inline  void reset_block_reg_mask(io_rw_32 *reset, uint32_t mask) {
    hw_set_bits(reset, mask);
}

static __force_inline  void unreset_block_reg_mask(io_rw_32 *reset, uint32_t mask) {
    hw_clear_bits(reset, mask);
}

static __force_inline void unreset_block_reg_mask_wait_blocking(io_rw_32 *reset, io_ro_32 *reset_done, uint32_t mask) {
    hw_clear_bits(reset, mask);
    while (~*reset_done & mask)
        tight_loop_contents();
}

/// \tag::reset_funcs[]

/*! \brief Reset the specified HW blocks
 *  \ingroup hardware_resets
 *
 * \param bits Bit pattern indicating blocks to reset. See \ref reset_bitmask
 */
static __force_inline void reset_block_mask(uint32_t bits) {
    reset_block_reg_mask(&resets_hw->reset, bits);
}

/*! \brief bring specified HW blocks out of reset
 *  \ingroup hardware_resets
 *
 * \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask
 */
static __force_inline void unreset_block_mask(uint32_t bits) {
    unreset_block_reg_mask(&resets_hw->reset, bits);
}

/*! \brief Bring specified HW blocks out of reset and wait for completion
 *  \ingroup hardware_resets
 *
 * \param bits Bit pattern indicating blocks to unreset. See \ref reset_bitmask
 */
static __force_inline void unreset_block_mask_wait_blocking(uint32_t bits) {
    unreset_block_reg_mask_wait_blocking(&resets_hw->reset, &resets_hw->reset_done, bits);
}

/// \end::reset_funcs[]

#ifndef HARDWARE_RESETS_ENABLE_SDK1XX_COMPATIBILITY
#define HARDWARE_RESETS_ENABLE_SDK1XX_COMPATIBILITY 1
#endif

#if HARDWARE_RESETS_ENABLE_SDK1XX_COMPATIBILITY
static __force_inline void reset_block(uint32_t bits) {
    reset_block_mask(bits);
}

static __force_inline void unreset_block(uint32_t bits) {
    unreset_block_mask(bits);
}

static __force_inline void unreset_block_wait(uint32_t bits) {
    return unreset_block_mask_wait_blocking(bits);
}
#endif

/*! \brief Reset the specified HW block
 *  \ingroup hardware_resets
 *
 * \param block_num the block number
 */
static inline void reset_block_num(uint32_t block_num) {
    reset_block_reg_mask(&resets_hw->reset, 1u << block_num);
}

/*! \brief bring specified HW block out of reset
 *  \ingroup hardware_resets
 *
 * \param block_num the block number
 */
static inline void unreset_block_num(uint block_num) {
    invalid_params_if(HARDWARE_RESETS, block_num > NUM_RESETS);
    unreset_block_reg_mask(&resets_hw->reset, 1u << block_num);
}

/*! \brief Bring specified HW block out of reset and wait for completion
 *  \ingroup hardware_resets
 *
 * \param block_num the block number
 */
static inline void unreset_block_num_wait_blocking(uint block_num) {
    invalid_params_if(HARDWARE_RESETS, block_num > NUM_RESETS);
    unreset_block_reg_mask_wait_blocking(&resets_hw->reset, &resets_hw->reset_done, 1u << block_num);
}

/*! \brief Reset the specified HW block, and then bring at back out of reset and wait for completion
 *  \ingroup hardware_resets
 *
 * \param block_num the block number
 */
static inline void reset_unreset_block_num_wait_blocking(uint block_num) {
    invalid_params_if(HARDWARE_RESETS, block_num > NUM_RESETS);
    reset_block_reg_mask(&resets_hw->reset, 1u << block_num);
    unreset_block_reg_mask_wait_blocking(&resets_hw->reset, &resets_hw->reset_done, 1u << block_num);
}


#endif // __HARDWARE_RESETS_H__
