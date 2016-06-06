#!/bin/bash
args=("$@")
ELEMENTS=${#args[@]}
argString=""
for (( i=0;i<$ELEMENTS;i++)); do
    argString=$argString" "${args[${i}]}
done
argString="--args$argString"
echo $argString
