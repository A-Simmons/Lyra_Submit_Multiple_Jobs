#!/bin/bash
cat $1 > INPUT
[ ! -f $INPUT ] && { echo "$INPUT could not be found"; exit 99; }

# Reads in the data file 'data.csv' and overwrites it to the file INPUT
dos2unix -q $2
cat $2 > INPUT
OLDIFS=$IFS

# Defines the seperator of the csv to be , (Comma)
IFS=','

# Checks file was actually found, if not, exit
[ ! -f $INPUT ] && { echo "$INPUT could not be found"; exit 99; }

# Read in the columns one line at a time. Add or remove f# as needed for number of columns in CSV
while read -a line; do
	echo
	echo '### '${line[0]}' ###'
	ParamString="scriptFile=$1,argString=--args"
	for i in "${!line[@]}"; do
		# [ Test values are part of argument list ] && [ Check if values are not empty ] && [ check values are not carriage return ]
		if [ "$i" -gt "2" ] && [ ${#line[i]} -gt "0" ] ; then
			# Add new parameter
			ParamString=$ParamString" ${line[i]}"
			echo "PARAM $(($i-2)): ${line[i]}"
		fi
	done
	ParamString="-v $ParamString"

	IFS=$OLDIFS
	qsub "$ParamString" -N ${line[0]} -l walltime=${line[1]} -l mem=${line[2]} subJob.pbs
	IFS=','
done < INPUT # Ends the loop

# Clean up
IFS=$OLDIFS
rm INPUT
