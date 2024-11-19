#!/bin/sh
ARG="${@: -1}"
DIR="$(dirname "${ARG}")"
SCR="${DIR}/tb.tcl"
questasim -do "${SCR}"
