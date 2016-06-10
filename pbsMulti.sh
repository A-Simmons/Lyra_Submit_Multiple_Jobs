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
	ParamStringBase="scriptFile=$1,argString=--args"
	repeat=1
	Jobname_base=""
	Walltime=""
	Memory=""
	# From each line read through each column
	for i in "${!line[@]}"; do
		# See if
		if [[ "${header_array[i]}" == "Jobname" ]]; then
			Jobname_base=${line[i]}
		elif [ "${header_array[i]}" == "Walltime" ]; then
			Walltime=${line[i]}
		elif	[ "${header_array[i]}" == "Memory" ]; then
			Memory=${line[i]}
		elif	[ "${header_array[i]}" == "Repeat" ]; then
			repeat=${line[i]}
		else
			# Add new parameter
			ParamStringBase=$ParamStringBase" ${header_array[i]}=${line[i]}"
			echo "${header_array[i]}: ${line[i]}"
		fi
	done
	ParamString="-v $ParamStringBase"

	# Submit job for loop if repeat > 1
	IFS=$OLDIFS
	for i in $(seq 1 1 $repeat); do
		# Add random seed the user can use 
		RNG_Seed=$RANDOM
		ParamString="-v $ParamStringBase""RNG_Seed=$RNG_Seed"

		# Adjust jobname that is sent as a parameter to R script if Job is being repeated
		Jobname=$Jobname_base
		if [ "$repeat" -ge "1" ]; then
			Jobname="$Jobname""_$i"
		fi
		ParamString=$ParamStringBase" Jobname=$Jobname"
		# Submit job to LYRA
		qsub "$ParamString" -N $Jobname -l walltime=$Walltime -l mem=$Memory subJob.pbs
	done
	IFS=','
done < INPUT # Ends the loop

# Clean up
IFS=$OLDIFS
rm INPUT
