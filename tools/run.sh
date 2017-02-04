#!/bin/sh
java -jar DCPU-Toolchain.jar run none --rom=$1 --clock --keyboard --lem1802 --lem1802-fps=10 --debugger
