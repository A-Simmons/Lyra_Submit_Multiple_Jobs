args<-commandArgs(TRUE)

a <- eval( parse(text=args[1]) )
b <- eval( parse(text=args[2]) )
c <- eval( parse(text=args[3]) )
print(a)
print(b)
print(c)
