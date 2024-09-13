#include "aux.h"
#include "gpio.h"

void uart_init() {
    /* Initialize UART */
    *AUX_ENABLES |= 1;   // Enable mini UART
    *AUX_MU_CNTL = 0;    // Disable TX, RX during configuration
    *AUX_MU_IER = 0;     // Disable interrupt
    *AUX_MU_LCR = 3;     // Set the data size to 8 bit
    *AUX_MU_MCR = 0;     // Don't need auto flow control
    *AUX_MU_BAUD = 270;  // Set baud rate to 115200
    *AUX_MU_IIR = 6;     // No FIFO

    /* Map UART to GPIO Pins */

    // 1. Change GPIO 14, 15 to alternate function
    register unsigned int r = *GPFSEL1;
    r &= ~((7 << 12) | (7 << 15));  // Reset GPIO 14, 15
    r |= (2 << 12) | (2 << 15);     // Set ALT5
    *GPFSEL1 = r;

    // 2. Disable GPIO pull up/down (Because these GPIO pins use alternate functions, not basic input-output)
    // Set control signal to disable
    *GPPUD = 0;
    // Wait 150 cycles
    r = 150;
    while (r--) {
        asm volatile("nop");
    }
    // Clock the control signal into the GPIO pads
    *GPPUDCLK0 = (1 << 14) | (1 << 15);
    // Wait 150 cycles
    r = 150;
    while (r--) {
        asm volatile("nop");
    }
    // Remove the clock
    *GPPUDCLK0 = 0;

    // 3. Enable TX, RX
    *AUX_MU_CNTL = 3;
}

void uart_send(char c){
    while(!(*AUX_MU_LSR & 0x20)){
        asm volatile("nop");
    }
    *AUX_MU_IO = c;
}

char uart_recv(void){
    while(!(*AUX_MU_LSR & 0x01)){
        asm volatile("nop");
    }
    return *AUX_MU_IO & 0xFF;
}

void uart_flush(){
    while(*AUX_MU_LSR & 0x01)
        *AUX_MU_IO;
}

void uart_sendstr(char* str){
    while(*str){
        if(*str == '\n')
            uart_send('\r');
        uart_send(*str++);
    }
}