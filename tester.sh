#!/bin/bash

argString="--args "
for i in {1..3}; do
	if [ "$i" -gt "1" ]; then
		argString=$argString" "
	fi
	argString=$argString$i
done

echo $argString
