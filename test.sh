#!/bin/bash

# Reads in the data file 'data.csv' and overwrites it to the file INPUT
cat data.csv > INPUT
OLDIFS=$IFS

# Defines the seperator of the csv to be , (Comma)
IFS=,

# Checks file was actually found, if not, exit
[ ! -f $INPUT ] && { echo "$INPUT could not be found"; exit 99; }

# Read in the columns one line at a time. Add or remove f# as needed for number of columns in CSV
while read f1 f2 f3 f4 f5 f6
do
	# echo command simply prints to consol, can be used a visual confirmation nothing wacky is going on
	echo "Name : $f1"
	echo "RunTime : $f2"
	echo "Memory : $f3"
	echo "Parameter1 : $f4"
	echo "Parameter2 : $f5"
	echo "Parameter3 : $f6"

	# Actually submit the job.
	# PARAM1 and PARAM2 are two mock parameters which are passed to the function itself.
	# - If you want more parameters to be passed append to the -v with a comma
	# -N defines the name of the job
	# - l walltime is the runtime designated
	# -l mem is the designated memory
	qsub -v PARAM1=$f4,PARAM2=$f5,PARAM3=$f6 -N $f1 -l walltime=$f2 -l mem=$f3 subJob.pbs

	echo ""
done < INPUT # Ends the loop

# Clean up
IFS=$OLDIFS
rm INPUT
