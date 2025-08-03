#! /usr/bin/env bash

REQUIRED_BIN="$HOME/openocd/src/openocd"

#APP_PATH="$HOME/pico/pico-examples/build"

#APP_NAME="/spi/spi_master_slave/spi_master/spi_master.elf"
#APP_NAME="/uart/hello_uart/hello_uart.elf"
#APP_NAME="/hello_world/usb/hello_usb.elf"
APP_NAME="/home/paul/BARE_PICO2/blink.elf"

APP="$APP_NAME"



if ! command -v "$REQUIRED_BIN" > /dev/null 2>&1; then
    echo "[ ERROR ] : binary '$REQUIRED_BIN' required but not installed !" 2>&1
    exit 1
fi

if ! command -v "$APP" > /dev/null 2>&1; then
    echo "[ ERROR ] : binary app $APP not present !" 2>&1
    exit 1
fi



sudo $REQUIRED_BIN -s $HOME/openocd/tcl -f interface/cmsis-dap.cfg -f target/rp2350.cfg -c "adapter speed 5000" -c "program $APP verify reset exit"
