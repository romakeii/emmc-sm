#!/bin/sh
ARG="${@: -1}"
DIR="$(dirname "${ARG}")"
SCR="${DIR}/create_testcore_project.tcl"
vivado -nolog -nojournal -mode tcl -source "${SCR}" -tclargs "${SCR}"
# Cleanup
find ./ -maxdepth 1 -name "*vivado*.jou" -delete
find ./ -maxdepth 1 -name "*vivado*.log" -delete
find ./ -maxdepth 1 -name ".Xil" | xargs rm -rf
