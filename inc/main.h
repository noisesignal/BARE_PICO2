// RM0394 https://www.st.com/resource/en/reference_manual/dm00151940-stm32l41xxx42xxx43xxx44xxx45xxx46xxx-advanced-armbased-32bit-mcus-stmicroelectronics.pdf

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#define MHZ	0xF4240
#define LED_PIN 25
#define OPMODE_STANDBY   0x01
#define OPMODE_MASK      0x07
#define RegOpMode        0x01
#define OPMODE_SLEEP     0x00


extern void _entry(void);
extern void _uart(void);
extern void _spi(void);
extern uint8_t _read_spi_reg(uint8_t);
extern void _write_spi_reg(uint8_t val, uint8_t addr);
extern void flip_led(void);
extern void _clksys(void);
extern void delay_ms(uint32_t millis);
extern void _systick(void);
static void opmode(uint8_t mode);

static const unsigned char eu863_lora_frequency[8][3] = {
	{0xD9, 0x06, 0x8B}, // Channel 0 868.100 MHz / 61.035 Hz = 14222987 = 0xD9068B
	{0xD9, 0x13, 0x58}, // Channel 1 868.300 MHz / 61.035 Hz = 14226264 = 0xD91358
	{0xD9, 0x20, 0x24}, // Channel 2 868.500 MHz / 61.035 Hz = 14229540 = 0xD92024
	{0xD8, 0xC6, 0x8B}, // Channel 3 867.100 MHz / 61.035 Hz = 14206603 = 0xD8C68B
	{0xD8, 0xD3, 0x58}, // Channel 4 867.300 MHz / 61.035 Hz = 14209880 = 0xD8D358
	{0xD8, 0xE0, 0x24}, // Channel 5 867.500 MHz / 61.035 Hz = 14213156 = 0xD8E024
	{0xD8, 0xEC, 0xF1}, // Channel 6 867.700 MHz / 61.035 Hz = 14216433 = 0xD8ECF1
	{0xD8, 0xF9, 0xBE} // Channel 7 867.900 MHz / 61.035 Hz = 14219710 = 0xD8F9BE
};
