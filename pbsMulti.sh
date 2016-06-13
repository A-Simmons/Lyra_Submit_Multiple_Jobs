#!/bin/bash

usage_str="Usage: $(basename $0) [-h] [-v] [-s submission_script.sub] rscript.R parameter_file.csv"

verbose=0

# default PBS submission script
subfile="rsubjob.sub"

while getopts hvs: opt; do
    case "$opt" in
        h) # helpv
            echo >&2 "$usage_str"
            exit 0
            ;;
        v) verbose=1
            ;;
        s) subfile="$OPTARG"
            ;;
        \?) # unknown flag
            echo >&2 "$usage_str"
            exit 1
            ;;
    esac
done
# get rid of option params
shift $((OPTIND-1))

# should be 2 parameters left
if [ $# -ne 2 ]; then
    echo >&2 "$usage_str"
    exit 1
else
    rscript=$1
    csvfile=$2
fi

# Check files exist
echo $subfile
[ ! -f $subfile ] && { echo "PBS submission script file $subfile could not be found"; exit 1; }
[ ! -f $rscript ] && { echo "R script file $rscript could not be found"; exit 1; }
[ ! -f $csvfile ] && { echo "CSV parameter file $csvfile could not be found"; exit 1; }

# if file is DOS format then convert to UNIX format
isdos=$(file "$csvfile" | grep CRLF)
if [ -n "$isdos" ]; then
    dos2unix -q $csvfile
fi

# Pull header from CSV file and create a string array
IFS=, read -r -a header_array <<< "$(head -n 1 "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)')"

jobnamecol=f1; jobwalltimecol=f2; jobcpuscol=f3; jobmemcol=f4; jobrparamscols=(); jobrepeat=();
for i in "${!header_array[@]}"; do
  if [ "${header_array[i]}" == "jobname" ]; then
    jobnames=( $(tail -n +2 "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -"f$(($i+1))") )
  elif [ "${header_array[i]}" == "walltime" ]; then
    jobwalltimes=( $(tail -n +2 "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -"f$(($i+1))") )
  elif  [ "${header_array[i]}" == "ncpus" ]; then
    jobcpus=( $(tail -n +2 "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -"f$(($i+1))") )
  elif  [ "${header_array[i]}" == "memory" ]; then
    jobmems=( $(tail -n +2 "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -"f$(($i+1))") )
  elif  [ "${header_array[i]}" == "repeat" ]; then
    jobrepeat=( $(tail -n +2 "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -"f$(($i+1))") )
  else
     jobrparamscols+="$(($i+1)),"
  fi
done

# Add repeat variable if not found in CSV file
if [ ${#jobrepeat[@]} -eq 0 ]; then
  for i in $(seq 1 1 ${#jobnames[@]}); do jobrepeat+=(1); done;
fi

# Remove last comma from jobparams and read the PBS specifics for the jobs, skipping empty or comment lines
jobrparamscols=${jobrparamscols:0:${#jobrparamscols}-1}
jobrparams=( $(tail -n +2 "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -f$jobrparamscols) )
# Seperate csv string into array for later use
IFS=, read -r -a jobrparamscols <<< "$jobrparamscols"

# Print to user jobs being sent to HPC
numjobs=${#jobnames[@]}
if [ $verbose -eq 1 ]; then
    echo -n "submitting $numjobs jobs to the cluster: "
    echo "${jobnames[@]}"
else
    echo "submitting $numjobs jobs to the cluster"
fi

# submit the jobs - note any errors in csv will be picked up by PBS
for (( i = 0;  i < $numjobs; i++ )); do
    # note we trim leading and trailing spaces with xargs
    name=$(echo ${jobnames[$i]} | xargs)
    walltime=$(echo ${jobwalltimes[$i]} | xargs)
    ncpus=$(echo ${jobcpus[$i]} | xargs)
    mem=$(echo ${jobmems[$i]} | xargs)
    repeat=$(echo ${jobrepeat[$i]} | xargs)

    # R params need csv delim replaced with a space
    rargs_base=""; IFS=, read -r -a rparams <<< "${jobrparams[$i]}"

    for (( j = 0;  j < ${#rparams[@]}; j++ )); do
      [ ! -z ${rparams[$j]} ] && { index=$((${jobrparamscols[$j]}-1)); rargs_base=$rargs_base"${header_array[$index]}=${rparams[$j]} "; }
    done

    for (( j = 0;  j < $repeat; j++ )); do
      name_r=$name"_$j"
      rargs_job="$rargs_base RNG_Seed=$RANDOM UI=$name_r"
      # then strip trailing spaces
      rargs_job=$(echo $rargs_job | xargs)
      # create R script submission string
      scriptstr="scriptFile=$rscript,argString=--args"
      [ -n "$rargs_job" ] && scriptstr="$scriptstr $rargs_job"
      if [ $verbose -eq 1 ]; then
          echo -n "submitting job $((i+1)) with: "
          echo qsub -v \"MC_CORES=$ncpus, $scriptstr\" -N $name_r -l walltime=$walltime -l select=1:ncpus=$ncpus:mem=$mem $subfile
      fi
      qsub -v "MC_CORES=$ncpus, $scriptstr" -N $name_r -l walltime=$walltime -l select=1:ncpus=$ncpus:mem=$mem $subfile
    done
done

# display jobs
if [ $verbose -eq 1 ]; then
    qstat -u $USER
fi
