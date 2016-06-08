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
``` shell
module load R/3.2.4_gcc
module load jags/4.1.0/gcc/4.4.7
```

### gdal and gdalUtils package
```shell
module load R/3.2.4_gcc
module load gdal/2.1.0/gcc/4.4.7
module load proj.4/4.9.3/gcc/4.4.7
```

## Potential Permissions Error
If you experience the following error 
```shell
-bash: ./pbsMulti.sh: Permission denied
```
then your version doesn't have execute permissions to run. This can be fixed by calling `chmod 555 pbsMulti.sh` to give read and execute permissions to most users write access to the user.

# Usage
## CSV file
The crux of this script is centred around the .csv file that holds the job specific parameters. All tables presently follow the structure:

| JOBNAME | WALLTIME | MEMORY | PARAMETER 1 | PARAMETER 2 | PARAMETER 3 |
| --- | --- | --- | --- | --- | --- |
| Example_Name | 10:30:00 | 100mb | 1 | '\"Some String\"' | 0.1 |
| Another_Example | 50:00:00 | 120gb | 0.01 | '\"Hello, World!\"' | 3.1428 |


As can be seen in the above example, the first 3 columns are restricted and must be:

1. Jobname: The name given to this sepcific job. It should act as a unique identifier for output files generated by R and the HPC.
2. Walltime: Maximum time to dedicate to this job in the format <hours>:<minutes>:<seconds> such that in the first row 10:30:00 is asking for 10hours and 30minutes while the example in the second row is asking for 50hours.
3. Maximum memory to allocate to this job. It is recommended to not ask for excessive memmory. The `<Jobname>.o<JobID>` gives both the walltime and memory statistics to aid in trimming requests for successive job submissions.

Values in any other columns are passed directly to the R script as arguments. The above example contains 3 parameters, however the script scales up and down depending on the number of columns used. 

### Restrictions
At present there are two major restrictions

1. Parameters must be numerical and strings
2. Strings can not contain commas since they conflict with the commas that seperate values in the .csv file. 

## Calling the script
Actually calling the script is as easy as using the standard `qsub` command. The template below needs two addition parameters: the R script to be called by the HPC and also where the parameters will be sent as well as the csv file to load the parameters. 
```shell
.pbsMulti <R_script.R> <parameter.csv>
```

For example, to call the [Rand Matrix example](https://github.com/A-Simmons/Lyra_Submit_Multiple_Jobs/tree/master/Rand_Matrix_Example), again we would need to copy the **subJobs.pbs** and **pbsMulti.sh** files into the Rand_Matrix_Example folder 
```shell
.pbsMulti rand_matrix_script.R rand_matrix_data.csv
```

# Task Lists
- [x] Bash script completely automated. User only needs to edit their .csv file and Rscript for basic needs 
- [ ] Add functionality to load more modules than just R
- [ ] Allow headers in CSV
