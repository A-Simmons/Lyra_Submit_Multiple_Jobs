To run code on the hpc use the command
./test.sh

You'll receive an output similar to

n8352747@lyra04:~/ShellScript_Example> ./test.sh
Name : FILENAME1
RunTime : 1:00:00
Memory : 100mb
Parameter1 : 1
Parameter2 : 2
Parameter3 : '"We"'
660073.pbs

Name : FILENAME2
RunTime : 2:00:00
Memory : 200mb
Parameter1 : 3
Parameter2 : 4
Parameter3 : '"Come"'
660074.pbs

Name : FILENAME3
RunTime : 3:00:00
Memory : 300mb
Parameter1 : 5
Parameter2 : 6
Parameter3 : '"In"'
660075.pbs

Name : FILENAME4
RunTime : 4:00:00
Memory : 400mb
Parameter1 : 7
Parameter2 : 8
Parameter3 : '"Peace"'
660076.pbs



#### test.sh ####
The test.sh file contains 3 important lines that need to be edited with a 3rd optional edit

The .csv file to read from is defined in line 4. In this case it is data.csv
Line 4: cat data.csv > INPUT

The following line tells the while loop to store the values from each successive column in the variables f1 through to f6 (data.csv has 6 columns in this example). This needs to be edited depending on the number of columns being read in from data.csv
Line 14: while read f1 f2 f3 f4 f5 f6

In line 30 the qsub command is called and all the values from data.csv are allocated. In this example the first column is the name given to the job. The second column is the amount of walltime. The third column is the memory allocation. Columns 4-6 are parameters to be sent to the R script itself.
Line 30:qsub -v PARAM1=$f4,PARAM2=$f5,PARAM3=$f6 -N $f1 -l walltime=$f2 -l mem=$f3 subJob.pbs



#### subJob.pbs ####
If you need modules in addition to R (such as rjags) you'll need to add them.

On line 11 the option "--args "$PARAM1" "$PARAM2" "$PARAM3"" is the component that sends the desired parameters/arguments to the R script. If you increase or decrease the number of parameters being sent you'll need to adjust this line accordingly.

The echo lines do not affect submission, rather your <jobName>.o file will print what the .pbs script is reading as the parameters, useful for diagnosing potential issues.



#### simpleFunction.R ####
At the top of your script the command args<-commandArgs(TRUE) is needed to read in the arguments being sent from the .pbs script.

Lines 3-6 store the arguments as objects in your R environment.



#### data.csv ####
To send strings the most be of the form
'\"<someString>\"'

For example:
'\"Hello, World!\"'

The single quotations tell the shell script to read the inner string literally rather than reading the \" as escape characters. The \" tell the R parser to read the command as a string rather than a literal object.

You can also send R commands through, avoid the use of spaces unless it is in a string else the shell script will crash.
