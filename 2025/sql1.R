# DataFrame 11
df11 <- data.frame(
  id = c(1, 2, 3),
  value_A = c("A1", "A2", "A3"))


# DataFrame 12
df12 <- data.frame(
  id = c(2, 3, 4),
  value_B = c("B2", "B3", "B4"))

install.packages("sqldf")
library(sqldf)

sqldf <- sqldf("SELECT a.id, a.value_A, b.value_B
                 FROM df11 a
                 INNER JOIN df12 b
                 ON a.id = b.id")
View(sqldf)

install.packages("DBI")
install.packages("RSQLite")
library(DBI)
library(RSQLite)

con <- dbConnect(RSQLite::SQLite(), ":memory:")
dbWriteTable(con, "df11", df11)
dbWriteTable(con, "df12", df12)

dbi1 <- dbGetQuery(con, "SELECT a.id, a.value_A, b.value_B
                 FROM df11 a
                 INNER JOIN df12 b
                 ON a.id = b.id")
View(dbi1)


install.packages("duckdb")
library(duckdb)

con <- dbConnect(duckdb())


dbWriteTable(con, "df11", df11)
dbWriteTable(con, "df12", df12)

duckdb <- dbGetQuery(con, "SELECT a.id, a.value_A, b.value_B
                           FROM df11 a
                           INNER JOIN df12 b
                           ON a.id = b.id")
