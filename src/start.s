.section ".text.boot"

.global _start

_start:
	mrs x0,mpdir_el1
	and x0,x0,#3
	cbz x0,setting
halt:
	wfe
	b halt

setting:
	ldr x1,=_start //load data from _start to register x1 value(0x8000)
	mov sp x1 //move a value x1 into stack pointer

	ldr x1,=__bss_start
	ldr x2,=__bss_size
clear_bss:
	cbz x2, kernel_main
//bss section init
	str xzr,[x1],#8 //write 64bits zero to the address x1 point to and shift 8
			//The main part of clearing bss section
	sub x2, x2, #1 	//decide clear bss times
	cbz x2,clear_bss
kernel_main:
	bl main
	b halt	
