import os
import argparse
from parameters import *

def get_bit(d, i): # starting from 1
	return ( d & (0x1  << (i - 1)) ) >> (i - 1)


def parse_instruction(instr):
	binary = 0
	if instr == 'nop':
		return '00000013'
	name = instr.split(' ')[0]
	args = instr.split(name)[1].strip().split(',') # no labels with names of opcodes
	args = [arg.strip() for arg in args]
	name = name.upper()
	binary += OPCODES[name]['opcode']
	binary += OPCODES[name]['funct3'] << 12 
	binary += OPCODES[name]['funct7'] << 25
	# print(args)
	instr_type = OPCODES[name]['type']
	if instr_type == 'U':
		assert len(args) == 2, 'Instruction not valid'
		rd, imm = args
		imm = int(imm)
		binary += REGISTERS[rd] << 7
		binary += imm << 12
	elif instr_type == 'J':
		assert len(args) == 2, 'Instruction not valid'
		rd, imm = args
		imm = int(imm)
		binary += REGISTERS[rd] << 7
		for i in range(12, 20):
			binary += get_bit(imm, i) << i
		binary += get_bit(imm, 11) << 20
		for i in range(1, 11):
			binary += get_bit(imm, i) << (20 + i)
		binary += get_bit(imm, 32) << 31
		binary &= 0xFFFFFFFF
	elif instr_type == 'I':
		assert len(args) == 3, 'Instruction not valid'
		rd, rs1, imm = args
		imm = int(imm)
		if imm < 0:
			imm = 0xFFFFFFFF + (imm + 1)
		binary += REGISTERS[rd] << 7
		binary += REGISTERS[rs1] << 15
		binary += (imm & 0x000007FF) << 20
		binary += get_bit(imm, 32) << 31
	elif instr_type == 'B':
		assert len(args) == 3, 'Instruction not valid'
		rs1, rs2, imm = args
		imm = int(imm)
		print(imm)
		binary += REGISTERS[rs1] << 15
		binary += REGISTERS[rs2] << 20
		binary += get_bit(imm, 11) << 7
		for i in range(1, 5):
			binary += get_bit(imm, i) << (7 + i)
		for i in range(5, 11):
			binary += get_bit(imm, i) << (20 + i)
		binary += get_bit(imm, 12) << 31
	elif instr_type == 'S':
		assert len(args) == 3, 'Instruction not valid'
		rs1, rs2, imm = args
		imm = int(imm)
		for i in range(1,6):
			binary += get_bit(imm, i) << (6 + i)
		binary += REGISTERS[rs1] << 15
		binary += REGISTERS[rs2] << 20
		for i in range(6, 13):
			binary += get_bit(imm, i) << (24 + i)
	elif instr_type == 'R':
		assert len(args) == 3, 'Instruction not valid'
		rd, rs1, rs2 = args
		binary += REGISTERS[rd] << 7
		binary += REGISTERS[rs1] << 15
		binary += REGISTERS[rs2] << 20
	else:
		raise Exception('Invalid instruction type')
	return '%0.8X' % binary


def parse_text(lines):
	parsed_text = []
	labels = {}
	mem_offset = 0
	for line in lines:
		if line == '.data':
			break
		if ':' in line:
			label = line[:-2].strip()
			labels[label] = mem_offset
			continue
		mem_offset += 1
	mem_offset = 0
	for i, line in enumerate(lines):
		line = line.strip()
		if line == '.data':
			break
		if ':' in line:
			continue
		if line == '':
			continue
		for label in labels:
			if label in line:
				print(labels[label])
				print(mem_offset)
				line = line.replace(label, str(4 * (labels[label] - mem_offset)))
		parsed_text.append(parse_instruction(line))
		mem_offset += 1
	return parsed_text, labels


def parse_data(lines):
	data = []
	return data

def parse_program(lines):
	for i, line in enumerate(lines):
		if line.strip() == '.text':
			if(len(lines) > i):
				text, labels = parse_text(lines[i+1:])
		elif line.strip() == '.data':
			if(len(lines) > i):
				data = parse_data(lines[i+1:])
	return text, labels, data

def asmtomem(filename):
	with open(filename, 'r') as f:
		lines = f.readlines()
	text, labels, data = parse_program(lines)
	mem = []
	for instr in text:
		for i in range(3, -1, -1):
			mem.append(instr[i*2:i*2+2])
	print(text)
	# print(labels)
	# print(data)
	# print(mem)
	return mem



def main(filename, outfile):
	mem = asmtomem(filename) 
	with open(outfile, 'w') as f:
		f.write('/* INSTRUCTION MEMORY CONTENT */\n')
		for b in mem:
			f.write(b + '\n')
		for i in range(4 * 4):
			f.write('00\n')

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument('-f', dest='filename', type=str, default='./program.asm')
	parser.add_argument('-o', dest='outfile', type=str, default='./instructions.mem')
	args = parser.parse_args()

	assert os.path.isfile(args.filename), 'ERROR: %s is not a file' % filename

	main(args.filename, args.outfile)
