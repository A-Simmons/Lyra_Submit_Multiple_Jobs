library(parallel)

args<-commandArgs(TRUE)

a <- eval( parse(text=args[1]) )
b <- eval( parse(text=args[2]) )
c <- eval( parse(text=args[3]) )
length(args)
print(a)
print(b)
print(c)

sprintf('running on node %s with %d cpus', Sys.info()[c("nodename")], getOption("mc.cores", 2L))


