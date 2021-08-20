.text
				addi x5, x0, 10
				nop
				nop
				nop
				nop
	loop:
				beq x5, x0, exit
				nop
				nop
				nop
				nop
				addi x5, x5, -1
				nop
				nop
				nop
				nop
				jal x0, loop
	exit:
				sw x0, x5, 0
				nop
				nop
	fine:
				jal x0, fine

.data
