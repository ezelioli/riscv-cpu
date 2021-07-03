import os
import argparse

def check_args(args):
	assert os.path.isfile(filename), 'ERROR: %s is not a file' % filename
	assert os.path.isfile(outfile), 'ERROR: %s is not a file' % outfile
	return args.filename, args.outfile


def decode(opcode, dst, src1, src2):
	return ['00', '00', '00', '00']


def main(args):
	filename, outfile = check_args(args)

	with open(filename, 'r') as file:
		lines = file.readlines()

	with open(outfile, 'w') as file:
		for i in range(len(lines)):
			# delete end of line
			line = lines[i][:-1]
			if line == '.text':
				i += 1
				while True:
					line = lines[i][-1]
					words = line.split(',')
					assert len(words) > 0 and len(words) < 5, 'Found invalid instruction %s' % line
					opcode = words[0].strip()
					dst, src1, src2 = ''
					if len(words) > 1:
						dst = words[1].strip()
						if len(words) > 2:
							src1 = words[2].strip()
							if len(words) > 3:
								src2 = words[3].strip()
					instr = decode(opcode, dst, src1, src2)
					for b in instr:
						file.write(b, '\n')
					i += 1
	



if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('-f', dest='filename', type=str, default='./program.asm')
	parser.add_argument('-o', dest='outfile', type=str, default='./instructions.mem')
	args = parser.parse_args()

	main(args)