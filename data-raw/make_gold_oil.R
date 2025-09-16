# data-raw/make_gold_oil.R
# Converts CSV -> .rda for package data

# Adjust the path if needed (during first build you can point to the CSV you have)
csv_path <- "gold_oil.csv"  # or an absolute path

stopifnot(file.exists(csv_path))
gold_oil <- read.csv(csv_path, stringsAsFactors = FALSE)

# minimal checks/cleanup
stopifnot(all(c("Gold", "Oil") %in% names(gold_oil)))
gold_oil <- gold_oil[, c("Gold", "Oil")]

# Save into data/
dir.create("data", showWarnings = FALSE)
save(gold_oil, file = "data/gold_oil.rda", compress = "bzip2")
