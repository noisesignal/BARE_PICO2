CROSS_COMPILE = arm-none-eabi-
CC = $(CROSS_COMPILE)gcc
LD = $(CROSS_COMPILE)ld
OBJCOPY = $(CROSS_COMPILE)objcopy
TINYUSBLIB = tinyusb

CFLAGS = -mcpu=cortex-m33 -mthumb -Os -ffreestanding -Wall -std=c11 -lc --specs=nano.specs
CFLAGS += -DRX_MODE -DSYSTICK_12MHZ

ASFLAGS = -DPICO_NO_FLASH=0 -DPICO_NO_RAM_VECTOR_TABLE=0 -DPICO_NO_STORED_VECTOR_TABLE=0
LDFLAGS = -T memmap_default.ld

#INCLUDES = -I/home/paul/pico/pico-sdk/src/common/boot_picobin_headers/include
#INCLUDES += -I/home/paul/pico/pico-sdk/src/rp2_common/cmsis/stub/CMSIS/Core/Include
#INCLUDES += -I/home/paul/pico/pico-sdk/src/rp2_common/cmsis/stub/CMSIS/Device/RP2350/Include
#INCLUDES = -I/home/paul/BARE_PICO2/CMSIS_6/CMSIS/Core/Include

INCLUDES += -I/home/paul/BARE_PICO2
INCLUDES += -I/home/paul/BARE_PICO2/PICO_INCLUDES
INCLUDES += -I/home/paul/BARE_PICO2/inc

INCLUDES += -I/home/paul/pico/pico-sdk/src/common/pico_stdlib_headers/include

TARGET = blink
OPENOCD_CFG = -f interface/cmsis-dap.cfg -f target/rp2350.cfg

AS_SRCS := $(wildcard ASM/*.S)
AS_OBJS := $(AS_SRCS:.S=.o)
C_SRCS := $(wildcard *.c)

C_OBJS := $(C_SRCS:.c=.o)
TINYUSB_SRC_C_ABS := $(addprefix $(TINYUSBLIB)/, $(TINYUSB_SRC_C))
C_OBJS += $(TINYUSB_SRC_C_ABS:.c=.o)


all: $(TARGET).elf

$(TARGET).elf: $(AS_OBJS) $(C_OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

%.o: %.S
	$(CC) $(CFLAGS) $(ASFLAGS)  -c $< -o $@

flash: $(TARGET).elf
	openocd $(OPENOCD_CFG) -c "adapter speed 5000" -c "program $(TARGET).elf verify reset exit"

server:
	openocd -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 5000"


clean:
	rm -f *.o *.elf
	rm -f ASM/*.o
