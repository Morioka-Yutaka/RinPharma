df21 <- data.frame(
  id = c(1, 2, 3),
  score = c(90, 80, 70)
)

df22 <- data.frame(
  id = c(2, 3, 4),
  score = c(85, 75, 65)
)

merged <- merge(df21, df22, by = "id")

View(df21)
View(df22)
View(merged)