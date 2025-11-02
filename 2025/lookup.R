kvlookup_dt <- function(x,
                        master,
                        key,             # character vector: key column names
                        var = NULL,      # character vector: variable names to retrieve (NULL = all columns except keys)
                        wh  = NULL,      # character scalar: data.table expression applied to master (e.g., quote(Age > 12) or "Age > 12")
                        warn = FALSE,    # whether to issue a warning when lookup keys are not found
                        overwrite = TRUE # whether to overwrite existing columns in x if names overlap
) {
  stopifnot(requireNamespace("data.table", quietly = TRUE))
  DTx <- data.table::as.data.table(x)
  DTm <- data.table::as.data.table(master)
  
  # --- Apply WHERE filter (wh) to master ---
  if (!is.null(wh) && nzchar(as.character(wh))) {
    # Allow both character and expression inputs for evaluation
    if (is.character(wh)) {
      wh_expr <- parse(text = wh)[[1]]
    } else {
      wh_expr <- wh
    }
    DTm <- DTm[eval(wh_expr)]
  }
  
  # --- Determine columns to keep (key + var) ---
  if (is.null(var)) {
    # If var is not specified, use all columns in master except keys
    var <- setdiff(names(DTm), key)
  }
  keep_cols <- unique(c(key, var))
  miss_cols <- setdiff(keep_cols, names(DTm))
  if (length(miss_cols)) {
    stop(sprintf("The following columns do not exist in master: %s", paste(miss_cols, collapse = ", ")))
  }
  DTm <- DTm[, ..keep_cols]
  
  # --- Add a matching flag to master (used to check hits after join) ---
  hit_col <- "__kv_hit__"
  while (hit_col %in% names(DTm)) hit_col <- paste0(hit_col, "_")
  DTm[, (hit_col) := TRUE]
  
  # --- Set key for faster join ---
  data.table::setkeyv(DTm, key)
  
  # --- Perform join (X[i] form; keep i = x to preserve its order and row count) ---
  # master[x, on=key] → keeps the number and order of i (=x) rows, with X (=master) columns first
  RES <- DTm[DTx, on = key]
  
  # --- Extract target columns (var) and merge them into x ---
  # Handle name conflicts
  dup_in_x <- intersect(var, names(DTx))
  if (length(dup_in_x) && !overwrite) {
    stop(sprintf("The following columns already exist in x (overwrite=FALSE): %s",
                 paste(dup_in_x, collapse = ", ")))
  }
  # Add new columns or overwrite existing ones (similar to SAS DATA step behavior)
  for (vn in var) {
    DTx[, (vn) := RES[[vn]]]
  }
  
  # --- Issue warnings (warn=TRUE when keys are non-NA but not found) ---
  if (isTRUE(warn)) {
    # "matched" = whether the master-side flag is TRUE
    matched <- isTRUE(RES[[hit_col]])
    matched[is.na(matched)] <- FALSE
    
    # "key_any_present" = at least one key is non-missing
    key_df <- RES[, ..key]
    key_any_present <- apply(!is.na(as.data.frame(key_df)), 1, any)
    
    not_found <- (!matched) & key_any_present
    if (any(not_found)) {
      # Log the missing key values
      msg_keys <- apply(as.data.frame(key_df[not_found]), 1, function(rw) {
        paste(sprintf("%s=%s", names(key_df), ifelse(is.na(rw), "NA", as.character(rw))), collapse = ", ")
      })
      warning(sprintf("kvlookup_dt: %d key(s) not found in master. Examples:\n%s",
                      sum(not_found),
                      paste(utils::head(msg_keys, 5), collapse = "\n")))
    }
  }
  
  # --- Remove temporary working column ---
  RES[, (hit_col) := NULL]
  
  # The result is a data.table where var columns are added to x
  return(DTx[])
}

library(data.table)


dm <- data.table(SUBJID = c("A001","A002","B001"),
                     AGE  = c(14,13,13),
                     SEX  = c("MALE","FEMALE","FEMALE"))

wk1 <- data.table(SUBJID = c("A001","A002","A003","B001"))

out <- kvlookup_dt(
  wk1, dm,
  key = "SUBJID",
  var = c("AGE","SEX")
)

keycheck_dt <- function(x,
                        master,
                        key,              # character vector: key column names
                        wh  = NULL,       # character or expression: filter applied to master (e.g., "AGE >= 15")
                        fl  = "exist_fl", # name of output flag column
                        cat = c("YN","NUM","Y")  # "YN"=Y/N, "NUM"=1/0, "Y"=Y/""
) {
  stopifnot(requireNamespace("data.table", quietly = TRUE))
  cat <- match.arg(cat)
  
  DTx <- data.table::as.data.table(x)
  DTm <- data.table::as.data.table(master)
  
  # --- apply WHERE filter (wh) on master ---
  if (!is.null(wh) && nzchar(as.character(wh))) {
    wh_expr <- if (is.character(wh)) parse(text = wh)[[1]] else wh
    DTm <- DTm[eval(wh_expr)]
  }
  
  # --- keep only key columns, unique keys are enough for existence check ---
  miss_cols <- setdiff(key, names(DTm))
  if (length(miss_cols)) {
    stop(sprintf("Columns not found in master: %s", paste(miss_cols, collapse = ", ")))
  }
  DTm <- unique(DTm[, ..key])
  
  # --- prepare master with a hit flag for join result ---
  hit_col <- "__key_hit__"
  while (hit_col %in% names(DTm)) hit_col <- paste0(hit_col, "_")
  DTm[, (hit_col) := TRUE]
  
  # --- set keys for fast join ---
  data.table::setkeyv(DTm, key)
  
  # --- left-join-like existence check against x (preserve x's order/rows) ---
  RES <- DTm[DTx, on = key]
  
  # FIX: vectorized match flag
  matched <- RES[[hit_col]]            # logical vector: TRUE or NA
  matched[is.na(matched)] <- FALSE     # NA -> FALSE
  
  # --- build the requested flag column on DTx ---
  if (cat == "YN") {
    DTx[, (fl) := ifelse(matched, "Y", "N")]
  } else if (cat == "NUM") {
    DTx[, (fl) := as.integer(matched)]  # 1 if exists, 0 otherwise
  } else if (cat == "Y") {
    DTx[, (fl) := ifelse(matched, "Y", "")]
  }
  
  invisible(DTx[])
}


library(data.table)


ae <- data.table(USUBJID = c("A001","A001","A003"),
                     AETERM  = c("AE 1", "AE 2", "AE 1"))
dm <- data.table(USUBJID = c("A001","A002","A003","A004"))
out1 <- keycheck_dt(dm, ae, key="USUBJID", fl="AEFL", cat="YN")

out1
#       Name EXIST_YN
# 1:   Alice        Y
# 2:   Carol        N
# 3: Barbara        Y
# 4:   Alice        Y

# 2) 数値（NUM）：存在→1、非存在→0
out2 <- keycheck_dt(x, master, key="Name", fl="EXIST_NUM", cat="NUM")
out2

# 3) "Y"モード：存在→"Y"、非存在→""（空文字）
out3 <- keycheck_dt(x, master, key="Name", fl="EXIST_Y_ONLY", cat="Y")
out3

# 4) WHERE相当（wh）で master を事前に絞る：Age >= 14 に存在するか？
out4 <- keycheck_dt(x, master, key="Name", wh="Age >= 14", fl="AGE14_EXIST", cat="YN")
out4
# → Aliceは Age=13 なので "N"（条件外）

