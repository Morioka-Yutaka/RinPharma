# DataFrame A
df11 <- data.frame(
  id = c(1, 2, 3),
  value_A = c("A1", "A2", "A3"),
  stringsAsFactors = FALSE
)

# DataFrame B
df12 <- data.frame(
  id = c(2, 3, 4),
  value_B = c("B2", "B3", "B4"),
  stringsAsFactors = FALSE
)

View(df11)
View(df12)

#inner_joined
inner_joined <- merge(df11, df12, by = "id")
View(inner_joined)

#full_outer_joined
full_outer_joined <- merge(df11, df12, by = "id", all = TRUE)
View(full_outer_joined)

#left_outer_joined
left_joined <- merge(df11, df12, by = "id", all.x = TRUE)
View(left_joined)

# cross_joined
cross_joined <- merge(df11, df12, by = NULL)
View(cross_joined)