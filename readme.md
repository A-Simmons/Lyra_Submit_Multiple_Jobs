# Lyra Submit Multiple Jobs
Making submitting multiple jobs to the Lyra HPC easy! 

This script is a no-dependency, easy to use solution for submiting multiple jobs to Lyra where each job requires different parameters to be loaded. Could be as something as simple as guaranteeing the random number generator seed is different for each job to a script that loads 50 parameters that change from job to job.

What originally took messing around with PBS scripts and creating multiple R scripts and pbs files then submitting `qsub` command after `qsub` command has been replaced a single .csv file and a single call of 

```shell
.pbsMulti <R_script.R> <parameter.csv>
```

# Installation
Copy the **subJobs.pbs** and **pbsMulti.sh** files into the directory that contains the R script you wish to pass arguments to. 

While using modules except `R/3.2.4_gcc` is not supported, you can add additional modules by editing the **subJobs.pbs** file to include below the module load R line, for example:

### R Jags package
``` 
module load R/3.2.4_gcc
module load jags/4.1.0/gcc/4.4.7
```

### gdal and gdalUtils package
```
module load R/3.2.4_gcc
module load gdal/2.1.0/gcc/4.4.7
module load proj.4/4.9.3/gcc/4.4.7
```

## Potential Permissions Error
If you experience the following error 
```
-bash: ./pbsMulti.sh: Permission denied
```
then your version doesn't have execute permissions to run. This can be fixed by calling `chmod 755 pbsMulti.sh` to give read and execute permissions to most users write access to the user.


# Usage



# Task Lists
- [x] Bash script completely automated. User only needs to edit their .csv file and Rscript for basic needs 
- [ ] Add functionality to load more modules than just R
- [ ] Allow headers in CSV
