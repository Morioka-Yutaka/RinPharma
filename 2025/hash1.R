install.packages("hash")
library(hash)

# Creating a Hash
h <- hash(keys = c("a", "b", "c"), values = c(1, 2, 3))

# Reference to a Value
h[["a"]]   # 1
h[["b"]]   # 2

# Add new elements
h[["d"]] <- 4

h[["z"]]  