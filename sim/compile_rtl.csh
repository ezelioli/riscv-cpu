#! /bin/tcsh -f

# Script for compiling RTL sourcecode

set VER=2019.3
set LIB=work
set SOURCEDIR=../rtl
set VLOGFLAGS="-pedanticerrors -svinputport=net"


if (-e $LIB) then
  rm -rf $LIB 
endif

# create library
questa-${VER} vlib $LIB

# compile SystemVerilog sourcecode
questa-$VER vlog -sv ${VLOGFLAGS} -work ${LIB} -f ${SOURCEDIR}/file.list

# compile testbench
questa-$VER vlog -sv ${VLOGFLAGS} -work ${LIB} -f ${SOURCEDIR}/tb/file.list

# optimize the design
#questa-$VER vopt -work ${LIB} +acc -o core_opt core
questa-$VER vopt -work ${LIB} +acc -o tb_top_opt tb_top
