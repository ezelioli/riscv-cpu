#! /bin/bash

# Script for compiling RTL sourcecode

VER=2019.3
LIB=work
SOURCEDIR=../rtl
VLOGFLAGS="-pedanticerrors -svinputport=net"


if [ -d $LIB ]; then
  rm -rf $LIB 
fi

# create library
questa-${VER} vlib $LIB

# compile SystemVerilog sourcecode
questa-$VER vlog -sv ${VLOGFLAGS} -work ${LIB} -f ${SOURCEDIR}/file.list

# compile testbench
questa-$VER vlog -sv ${VLOGFLAGS} -work ${LIB} -f ${SOURCEDIR}/tb/file.list

# optimize the design
#questa-$VER vopt -work ${LIB} +acc -o core_opt core
questa-$VER vopt -work ${LIB} +acc -o tb_top_opt tb_top
