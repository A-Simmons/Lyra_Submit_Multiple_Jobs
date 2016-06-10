#!/bin/bash

# Check that the script file was actually found
cat $1 > INPUT
[ ! -f $INPUT ] && { echo "$INPUT could not be found"; exit 99; }

# Reads in the data file and overwrites it to the file INPUT
dos2unix -q $2
tail -n +2 $2 > INPUT
# Checks file was actually found, if not, exit
[ ! -f $INPUT ] && { echo "$INPUT could not be found"; exit 99; }

# Defines the seperator of the csv to be , (Comma)
OLDIFS=$IFS
IFS=','

# Pull header from CSV file and create a string array
read -r -a header_array <<< "$(head -n 1 $2)"

# Read in the rows one line at a time.
while read -a line; do
	echo
	echo '### '${line[0]}' ###'
	# ParamString holds the argument string for passing all the arguments/parameters
	ParamString="scriptFile=$1,argString=--args"

	# From each line read through each column
	for i in "${!line[@]}"; do
		# [ Test values are part of argument list ] && [ Check if values are not empty ]
		if [ "$i" -gt "2" ] && [ ${#line[i]} -gt "0" ] ; then
			# Add new parameter
			ParamString=$ParamString" ${header_array[i]}=${line[i]}"
			echo "${header_array[i]}: ${line[i]}"
		fi
	done
	ParamString="-v $ParamString"

	# Submit job
	IFS=$OLDIFS
	qsub "$ParamString" -N ${line[0]} -l walltime=${line[1]} -l mem=${line[2]} subJob.pbs
	IFS=','
done < INPUT # Ends the loop

# Clean up
IFS=$OLDIFS
rm INPUT
