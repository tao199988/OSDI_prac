#include "uart.h"


int main(){
    uart_init();

    uart_sendstr("Hello world!");

    while (1) {
        uart_send(uart_recv());
    }
}