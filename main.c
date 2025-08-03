#include <stdio.h>
#include "rfm95w.h"
#include "main.h"


static inline void delay(volatile int count) {
    while (count-- > 0) __asm__("nop");
}

static void opmode(uint8_t mode) {
    _write_spi_reg(RegOpMode, (_read_spi_reg(RegOpMode) & ~OPMODE_MASK) | mode);
}


void main(void) {
//_clksys();
_uart();
_spi();
_entry();
_systick();
//SysTick_Config(12000);
#if defined RX_MODE

        uint8_t reg;

        opmode(OPMODE_SLEEP);
        reg = _read_spi_reg(RegOpMode);
        while ( ( reg & RF_OP_MD ) != RF_OP_MD_SLEEP ) {
        reg = _read_spi_reg( RF_OPMODE );
        }

        reg &= ~( RF_OP_FREQ | RF_OP_MOD );
        reg |=  ( RF_OP_FREQ_HF | RF_OP_MOD_LORA );
        _write_spi_reg(RegOpMode, reg );
        reg = _read_spi_reg( RF_OPMODE );

        opmode(OPMODE_STANDBY);
        reg = _read_spi_reg( RF_OPMODE );
        while ( ( reg & RF_OP_MD ) != RF_OP_MD_STDBY ) {
        reg = _read_spi_reg( RF_OPMODE );
        }

        uint8_t channel = 0;
        _write_spi_reg(RF_FREQ_MSB, eu863_lora_frequency[channel][0]);
        _write_spi_reg(RF_FREQ_MID, eu863_lora_frequency[channel][1]);
        _write_spi_reg(RF_FREQ_LSB, eu863_lora_frequency[channel][2]);


        // Clear all interrupt request flags
        _write_spi_reg( RF_IRQ_FLAGS, 0x00 );

        // set bandwidth to 125 khz and coding rate to 4/8
        reg = 0x00;
        reg |= 0b01111000;
        _write_spi_reg( RegModemConfig1, reg );

        // Spreading factor 12
        reg = 0x00;
        reg |= 0b11000000;
        _write_spi_reg( RegModemConfig2, reg );

	/////// RX SECTION /////////////////////////////////////////////
 
	// Set the base FIFO address to 0.
    _write_spi_reg( RF_FIFO_RXBASE, 0x00 );

    // Enter 'continuous receive' mode.
    reg = _read_spi_reg( RF_OPMODE );
    reg &= ~( RF_OP_MD );
    reg |=  ( RF_OP_MD_RXC );
    _write_spi_reg( RF_OPMODE, reg );

    // Receive data loop.
    while( 1 ) {
  
    //  u1_t r = readReg(0X11);
    //        printf("RSSI: 0x%02X\r\n", r);
    //        printf("ENTERING LOOP\r\n");

    // Wait for a 'receive done' or 'CRC error' interrupt request.
      // (There is no 'receive timeout' in continuous mode)
      reg = _read_spi_reg( RF_IRQ_FLAGS );
      while( ( reg & ( RF_IRQ_RX_DONE | RF_IRQ_CRC_ERROR ) ) == 0 ) {
        reg = _read_spi_reg( RF_IRQ_FLAGS );
        printf( "ReqIrqFlag: 0x%02X\r\n", reg );
        // Check receive status every half-second or so.

        delay_ms( 1000 );
//	for (int count = 0; count < 1000000; count++) __NOP();
//        for ( uint32_t j=0; j < 500; j++ );

      }
      // Clear all interrupt request flags.
      _write_spi_reg( RF_IRQ_FLAGS, 0xFF );
      // Set FIFO address to the start of received data.
      reg = _read_spi_reg( RF_FIFO_RXADDR );
      printf( "RX@: 0x%02X\r\n", reg );
      _write_spi_reg( RF_FIFO_ADDR, reg );
      // Check how many bytes of data were received.
      uint8_t rx_len = _read_spi_reg( RF_RX_LEN );
      printf( "RXL: 0x%02X\r\n", rx_len );
      // Read data out of the FIFO and print it.
      for ( uint8_t i = 0; i < rx_len; ++i ) {
        reg = _read_spi_reg( RF_FIFO );
      //  printf( "R%d: 0x%02X\r\n", i, reg );
//        debug_char(reg);
	printf("%c", reg);
      }
        printf("\r\n");
        uint8_t r = _read_spi_reg(LORARegRssiValue);
        printf("RSSI: 0x%02X\r\n", r);
//      debug_char(r);
    }


#endif

uint8_t result;
  while (1) {
//    for (int i = 0; i < 5000000; i++) __NOP();
	delay_ms(1000);
	flip_led();
	result = _read_spi_reg(0x42);
	printf("Valeur printf: 0x%02X\r\n", result);  	
	}

}


