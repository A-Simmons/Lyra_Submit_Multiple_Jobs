Ensuring you've placed the simpleFunction.R and data.csv in the same folder as the pbsMulti.sh and subJob.pbs scripts. 

To run code on the hpc use the command
./pbsMulti.sh <R_script.R> <data_file.csv>

For each job you'll receive as 
JOBNAME.oJOBID
JOBNAME.eJOBID
JOBNAME.out

You'll receive an output similar to
n8352747@lyra04:~/ShellScript_Example> ./pbsMulti.sh simpleFunction.R data.csv 

### FILENAME1 ###
PARAM 1: 1
PARAM 2: 2
PARAM 3: '"We"'
PARAM 4: 4
665596.pbs

### FILENAME2 ###
PARAM 1: 3
PARAM 2: 4
PARAM 3: '"Come"'
PARAM 4: 4
PARAM 5: 5
665597.pbs

### FILENAME3 ###
PARAM 1: 5
PARAM 2: 6
PARAM 3: '"In"'
PARAM 4: 10
PARAM 5: 11
PARAM 6: 6
665598.pbs

### FILENAME4 ###
PARAM 1: 7
PARAM 2: 8
PARAM 3: '"Peace"'
PARAM 4: 1
PARAM 5: 2
PARAM 6: 3
PARAM 7: 7
665599.pbs

### rawr ###
PARAM 1: 1.2
PARAM 2: 9
PARAM 3: 3
665600.pbs

#### simpleFunction.R ####
At the top of your script the command args<-commandArgs(TRUE) is needed to read in the arguments being sent from the .pbs script.

Line 3 gives the number of arguments that have been passed to the function
length(args)

Lines 5-8 store the arguments as objects in your R environment.
a <- eval( parse(text=args[1]) )
b <- eval( parse(text=args[2]) )
c <- eval( parse(text=args[3]) )

Lines 8-10 print the three stored parameters
print(a)
print(b)
print(c)


#### data.csv ####
Column 1: Restricted to the name of the Job (JOBNAME)
Column 2: Restricted to wall tile <hours>:<mins>:<secs> eg 01:30:00 is 1hr and 30mins
Column 3: Restricted to memory reserved for job
Columns 4+: Arguments to be passed to R script

To send strings the most be of the form
'\"<someString>\"'

For example:
'\"Hello, World!\"'

The single quotations tell the shell script to read the inner string literally rather than reading the \" as escape characters. The \" tell the R parser to read the command as a string rather than a literal object.

The functionality to send R commands is being worked on. The limiting factor at the moment is the use of commas as seperators in R also acting as seperators for parameters in the CSV. 
