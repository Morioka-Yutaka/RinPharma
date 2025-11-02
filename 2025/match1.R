df41 <- data.frame(
  ID = c(101, 102, 103, 104),
  Name = c("Alice", "Bob", "Carol", "Dave")
)

df42 <- data.frame(
  ID = c(103, 101, 105),
  Score = c(88, 85, 90)
)

match <- df41
match$Score <- df42$Score[ match(df41$ID, df42$ID) ]

View(df41)
View(df42)
View(match)