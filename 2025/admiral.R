install.packages("admiral")
library(admiral)
library(dplyr)

adae <- tibble(USUBJID = c("A001","A001","A003"),
                 AETERM  = c("AE 1", "AE 2", "AE 1"))
adsl <- tibble(
  USUBJID = c("A001","A002","A003","A004"),
  TRTSDT = as.IDate(c("2024-01-10","2024-01-12","2024-01-15","2024-01-18"))
)

adae_1 <- derive_vars_merged(
  dataset = adae,
  dataset_add = adsl,
  by_vars = exprs(USUBJID),
  new_vars = exprs(TRTSDT)
)

adsl_1 <- derive_var_merged_exist_flag(
  dataset     = adsl,                 
  dataset_add = adae,
  by_vars     = exprs(USUBJID),
  condition   = TRUE,
  new_var     = AEFL,                 
  true_value  = "Y",
  false_value = "N" ,
  missing_value= "N"
)

