#! /bin/tcsh -f

# Script for compiling RTL sourcecode

set VER=2019.3
set LIB=rtl
set SOURCEDIR=../rtl
set VLOGFLAGS=-pedanticerrors


if (-e $LIB) then
  rm -rf $LIB 
endif

questa-${VER} vlib $LIB

# compile SystemVerilog sourcecode
questa-$VER vlog -sv -work ${LIB} -f ${SOURCEDIR}/file.list

# compile testbench
questa-$VER vlog -sv ${VLOGFLAGS} -work ${LIB} -f ${SOURCEDIR}/tb/file.list

# optimize the design
questa-$VER vopt -work ${LIB} +acc -o tb_top_opt tb_top
