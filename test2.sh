#!/bin/bash

# Reads in the data file 'data.csv' and overwrites it to the file INPUT
cat data.csv > INPUT
OLDIFS=$IFS

# Defines the seperator of the csv to be , (Comma)
IFS=','

# Checks file was actually found, if not, exit
[ ! -f $INPUT ] && { echo "$INPUT could not be found"; exit 99; }

# Read in the columns one line at a time. Add or remove f# as needed for number of columns in CSV
while read -a line; do
	# echo command simply prints to consol, can be used a visual confirmation nothing wacky is going on
	ParamString="-v "
	for i in "${!line[@]}"; do
		if [ "$i" -gt "2" ]; then
			# Add comma seperators
			if [ "$i" -gt "3" ]; then
				ParamString=$ParamString"$IFS"
			fi
			# Add new parameter
			ParamString=$ParamString"PARAM$(($i-2))=${line[i]}"
			echo "PARAM $(($i-2)): ${line[i]}"
		fi
	done
	IFS=$OLDIFS
	qsub "$ParamString" -N ${line[0]} -l walltime=${line[1]} -l mem=${line[2]} subJob2.pbs
	IFS=','
done < INPUT # Ends the loop

# Clean up
IFS=$OLDIFS
echo $ParamString
rm INPUT
