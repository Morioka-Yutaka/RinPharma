install.packages("dplyr")
library(dplyr)
wk1 <- tibble(id = 1:3, val = c("A", "B", "C"))
wk2 <- tibble(id = 2:4, val = c("D", "E", "F"))

out1 <- full_join(wk1, wk2, by = "id")

View(wk3)
View(out4)

install.packages("sassy")
library(sassy)

out2 <- rows_upsert(wk1, wk2, by = "id")

wk1 <- tibble(id = 1:3, val = c("A", "B", "C"))
wk3 <- tibble(id = 2:4, val = c("D", "E", "F"),val2 = c("D", "E", "F") )
out3 <- rows_upsert(wk1, wk3, by = "id")

out1 <- full_join(wk1, wk2, by = "id")

library(sassy)
out4 <- datastep(
  merge(wk1, wk3, by = "id", type = "full"),
  {}
)