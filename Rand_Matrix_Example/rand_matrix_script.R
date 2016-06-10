args<-commandArgs(TRUE)

# Set some defaults
seed <- 1
rows <- 10
cols <- 10

# Replace defaults with arguments if they exist
for(i in 1:length(args)){
  eval(parse(text=args[[i]]))
}

set.seed(seed)
print(c(seed, rows, cols))
print(matrix(rexp(200, rate=.1),rows,cols))
