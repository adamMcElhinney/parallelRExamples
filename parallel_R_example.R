install.packages('doParallel')
library('doParallel')
library('foreach')


# Find out how many cores are available (if you don't already know)
detectCores()
stopCluster(cl)
# Create cluster with desired number of cores
# Recommend using one less than the available cores, so you can
# still do other things with your laptop
cl <- makeCluster(detectCores()-1)
# Register cluster
registerDoParallel(cl)
# Find out how many cores are being used
getDoParWorkers()


# 3 main ways of running things in parallel (descending order of preference)
# 1. Other libraries (like caret)
# 2. parallel apply functions
# 3. foreach

# For-each
startVal = 1
endVal = 10000
combine = 'c'

x <- foreach(
            # Notice that this uses "=", not "in" like a normal for-loop
            i = startVal : endVal,
             # Do you want to combine the results?
             # If so, state the operator you want to use as a string
             # Using "c" will create a numeric vector from the results
             # You can pass in your own defined function as well
             # If not argument provided, defaults to a list
             .combine = combine) %dopar% {
               # What do you want to do? The logic goes here
              sqrt(i)
              }

# Notice how we can use combine to add the results
combine = "+"
x1 <- foreach(i = startVal : endVal,
             .combine = combine) %dopar% {
               sqrt(i)
             }
head(x1)


# Compare the timings
# Parallel: ~ 4.1

system.time(foreach(i = startVal : endVal) %dopar% {
                      sqrt(i)
                    }
            )

# Not parallel: ~ .016
system.time(for(i in startVal : endVal) {
  sqrt(i)
})

# WHAT!? Why is the non-parallel code faster?
# Keep in mind there is overhead to making things parallel. For small number of
# iterations or simple logic, the benefits of parallelization may not
# eclipse the overhead associated with it

# Let's try something a little more numerically intense
max.eig <- function(N, sigma) {
  d <- matrix(rnorm(N**2, sd = sigma), nrow = N)
  E <- eigen(d)$values
  abs(E)[[1]]
}


# Compare the timings
# Parallel: ~ 25 seconds
endVal = 100
system.time(
  foreach(i = startVal : endVal) %dopar% {
      max.eig(500,1)
      }
)

# Not parallel: ~ 109 seconds
system.time(
  for(i in startVal : endVal) {
      max.eig(500, 1)
    }
  )

# Note that if any packages are required for your code, you need to pass
# those in using the packages argument
foreach(i = startVal : 10, .packages = c('MASS')) %dopar% {
  print(i)
}


# 2nd way to parallelize code: parallel apply functions
endVal = 10000
system.time(parLapply(cl, list(1:endVal), sqrt))
system.time(lapply(list(1:endVal), sqrt))


# 3rd way to parallelize code; using specific packages
# 1. caret
# 2. plyr
# 3. dclone
# 4. pls


# Homework: Parallelize fitting of these random forests
library(randomForest)
x <- matrix(runif(500), 100)
y <- gl(2, 50)

# 4.2 seconds
system.time(
  for(i in seq(10, 1000, 10)) {
    randomForest(x = x, y =y, ntree = i)
    }
)


# 1.2 secoonds
system.time(
  foreach(i = seq(10, 1000, 10), .packages = 'randomForest') %dopar% {
    randomForest(x = x, y =y, ntree = i)
  }
)
