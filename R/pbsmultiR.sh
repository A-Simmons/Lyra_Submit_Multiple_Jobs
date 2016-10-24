#!/bin/bash

usage_str="Usage: $(basename $0) [-h] [-v] [-s submission_script.sub] rscript.R parameter_file.csv"

verbose=0

# default PBS submission script
subfile="rsubjob.sub"

while getopts hvs: opt; do
    case "$opt" in
        h) # help
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
[ ! -f $subfile ] && { echo "PBS submission script file $subfile could not be found"; exit 1; }
[ ! -f $rscript ] && { echo "R script file $rscript could not be found"; exit 1; }
[ ! -f $csvfile ] && { echo "CSV parameter file $csvfile could not be found"; exit 1; }

# if file is DOS format then convert to UNIX format
isdos=$(file "$csvfile" | grep CRLF)
if [ -n "$isdos" ]; then
    dos2unix -q $csvfile
fi

# read the PBS specifics for the jobs, skipping empty or comment lines
jobnames=( $(cat "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -f1) )
jobwalltimes=( $(cat "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -f2) )
jobcpus=( $(cat "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -f3) )
jobmems=( $(cat "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -f4) )

# read the R parameters for the jobs
# note that strip commas later otherwise each parameter ends up in its own array element
jobrparams=( $(cat "$csvfile" | egrep -v '(^#|^\s*$|^\s*\t*#)' | cut -d ',' -f5-) )

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

    # R params need csv delim replaced with a space
    rargs="${jobrparams[$i]//,/ }"
    # then strip trailing spaces
    rargs=$(echo $rargs | xargs)
    # create R script submission string
    scriptstr="scriptFile=$rscript,argString=--args"
    [ -n "$rargs" ] && scriptstr="$scriptstr $rargs"

    if [ $verbose -eq 1 ]; then
        echo -n "submitting job $((i+1)) with: "
        echo qsub -v \"MC_CORES=$ncpus, $scriptstr\" -N $name -l walltime=$walltime -l select=1:ncpus=$ncpus:mem=$mem $subfile
    fi
    qsub -v "MC_CORES=$ncpus, $scriptstr" -N $name -l walltime=$walltime -l select=1:ncpus=$ncpus:mem=$mem $subfile
done

# display jobs
if [ $verbose -eq 1 ]; then
    qstat -u $USER
fi
