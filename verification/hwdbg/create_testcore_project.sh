#!/bin/sh
ARG="${@: -1}"
DIR="$(dirname "${ARG}")"
SCR="${DIR}/create_testcore_project.tcl"
vivado -nolog -nojournal -mode tcl -source "${SCR}" -tclargs "${SCR}"
