#install.packages("dplyr")
library(dplyr)

df31 <- tibble(
  id = c(1, 2, 3),
  value_A = c("A1", "A2", "A3")
)

df32 <- tibble(
  id = c(2, 3, 4),
  value_B = c("B2", "B3", "B4")
)


inner_join <- inner_join(df31, df32, by = "id")
full_join <- full_join(df31, df32, by = "id")
left_join <- left_join(df31, df32, by = "id")
cross_join <- cross_join(df31, df32)

cross_join2 <- df31 %>% 
  mutate(dummy = 1) %>% 
  inner_join(df32 %>% mutate(dummy = 1), by = "dummy") %>% 
  select(-dummy)

View(cross_join2)