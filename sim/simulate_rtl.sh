#!/bin/bash

# Script to run rtl simulation

VER=2019.3
LIB=work

questa-${VER} vsim -lib ${LIB} tb_top_opt &