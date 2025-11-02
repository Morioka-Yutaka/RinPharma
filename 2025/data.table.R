library(data.table)
dt51 <- data.table(id = c(1,2,3), val1 = c("A","B","C"))
dt52 <- data.table(id = c(2,3,4), val2 = c(10,20,30))


# Inner Join
dt_out1 <- dt51[dt52, on = .(id), nomatch=0]

# left Outer Join(dt1 on the left side as the reference)
dt_out2 <- dt52[dt51, on = .(id)]

# full outer join
dt_out3 <- merge(dt51, dt52, by="id", all=TRUE)
data.table::merge.data.table(dt1, dt2, by = "id", all = TRUE)

getS3method("merge", "data.table")

#cross join
dt51_ <- dt51[, key := 1]
dt52_ <- dt52[, key := 1]
dt_out4 <- dt51_[dt52_, on=.(key), allow.cartesian=TRUE][, key := NULL]

#Rolling Join
dt_time <- data.table(time = c(1,5,10), value = c("a","b","c"))
dt_query <- data.table(time = c(2,6,9))

#Join the most recent past value
dt_out5 <- dt_time[dt_query, on=.(time), roll=TRUE]


# Non-equal Join
dt_range <- data.table(start = c(1,5), end = c(3,10), label=c("low","high"))
dt_point <- data.table(x = 1:10)

# Combine elements where x is within the range start <= x <= end
dt_out6 <- dt_range[dt_point, on=.(start <= x, end >= x), nomatch=0]


# Non-equal Join 
# Get the nearest previous or next value (without rolling)
X <- data.table(time = c(1, 5, 10), value = c("a", "b", "c"))
Y <- data.table(time = c(2, 6, 9))
setkey(X, time)

# Nearest previous (time < y)
prev <- X[Y, on = .(time < time), mult = "last"]

# Non-equal Join
#Matching within a +-tolerance band
#Use non-equi conditions to find all matches inside [u − tol, u + tol],
#then pick the closest one (dist = abs(t − u)).
# Match within the tolerance band
X <- data.table(id=1, t=c(1,5,9,12), val=c("A","B","C","D"))
Y <- data.table(id=1, u=c(2,6,11), tol=c(2,1,3))
setkey(X, id, t)

# Precompute join columns
Y[, lower := u - tol]
Y[, upper := u + tol]

# Now perform the join safely
hits <- X[Y, on = .(id, t >= lower, t <= upper),
          nomatch=0,
          .(id, u, tol, t, val, dist = abs(t - u))]

# Keep only the closest match per (id,u)
nearest <- hits[order(id, u, dist)][, .SD[1], by=.(id, u)]

