.text
				lw x6, x0, var2
				addi x6, x6, 1
				addi x5, x0, 10
	loop:
				addi x6, x6, 1
				addi x5, x5, -1
				bne x5, x0, loop
				sw x0, x6, var1
	fine:
				jal x0, fine

.data
	var1: 0x00000001
	var2: 0x01000000
