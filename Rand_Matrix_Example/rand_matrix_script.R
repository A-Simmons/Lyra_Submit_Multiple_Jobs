args<-commandArgs(TRUE)

# Set some defaults
seed <- 1
n <- 10
m <- 10

# Replace defaults with arguments if they exist
nargs = length(args)
if (nargs >= 1) {
  seed <- eval( parse(text=args[1]))
  if (nargs >= 2) {
    n <- eval( parse(text=args[2]))
    if (nargs >= 3) {
      m <- eval( parse(text=args[3]))
    }
  }
}
set.seed(seed)


print(c(seed, n, m))
print(matrix(rexp(200, rate=.1),nrow=n,ncol=m))