.text
				addi x6, x0, 1
				nop
				nop
				nop
				nop
				addi x5, x0, 10
				nop
				nop
				nop
				nop
	loop:
				addi x6, x6, 1
				nop
				nop
				nop
				nop
				addi x5, x5, -1
				nop
				nop
				nop
				nop
				bne x5, x0, loop
				nop
				nop
				nop
				sw x0, x6, 0
				nop
				nop
	fine:
				jal x0, fine

.data