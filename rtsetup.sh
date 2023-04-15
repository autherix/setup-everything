#!/usr/bin/env bash

rt=/ptv
alias rt='cd /ptv'
alias rtsetup='source $rt/rtsetup.sh'
function seterror() { errmsg=$1; echo -e "\e[31m[ERR] $errmsg\e[0m"; exit 1; }
