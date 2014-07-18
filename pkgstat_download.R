today <- Sys.Date() - 1
start <- today - 30

all_days <- seq(start, today, by = 'day')

# You can then use download.file to download into a directory.

# If you only want to download the files you don't have, try:
missing_days <- setdiff(as.character(all_days), tools::file_path_sans_ext(dir(), TRUE))
missing_days <- as.Date(missing_days)
year <- as.POSIXlt(missing_days)$year + 1900
if (length(missing_days) > 0) {
  urls <- paste0('http://cran-logs.rstudio.com/', year, '/', missing_days, '.csv.gz')
  for(i in seq_along(urls)) {
    download.file(urls[i], sprintf("%s.csv", missing_days[i]))
  }
}

library(dplyr)
library(data.table)
df <- list()
pb <- txtProgressBar(max = length(all_days), style = 3)
for(i in seq_along(all_days)) {
  df[[i]] <- data.table(read.csv(sprintf("%s.csv", all_days[i]), stringsAsFactors = FALSE, 
                      colClass = rep("character", 10)))
  setTxtProgressBar(pb, i)
}
close(pb)
df <- do.call(rbind, df)
gc()

library(sos)
library(fImport)
get_pkg_list <- function(keyword, maxPages = 20) {
  r <- findFn(keyword, maxPages = maxPages)
  writeFindFn2xls(r, file.="sos.xls")
  src <- read.xls("sos.xls")
  retval <- sapply(strsplit(src, ","), function(s) s[1])
  attr(retval, "src") <- src
  retval
}
get_score <- function(obj) {
  src <- attr(obj, "src")
  r <- sapply(strsplit(src, ","), function(s) as.integer(s[4]))  
  r[is.na(r)] <- 1
  names(r) <- obj
  r
}

pkg.sql <- get_pkg_list("SQL")
pkg.sql.score <- sapply(strsplit(attr(pkg.sql, "src"), ","), function(s) as.integer(s[4]))
pkg.sql.score[is.na(pkg.sql.score)] <- 0
names(pkg.sql.score) <- pkg.sql

pkg.database <- get_pkg_list("database")
pkg.database.score <- sapply(strsplit(attr(pkg.database, "src"), ","), function(s) as.integer(s[4]))
pkg.database.score[is.na(pkg.database.score)] <- 0
names(pkg.database.score) <- pkg.database

pkg_list <- union(names(which(pkg.sql.score > 30)), names(which(pkg.database.score > 30)))

pkg_list
df.pkg_downloads <- summarise(group_by(df, package), count = length(country))
data.table::setkey(df.pkg_downloads, "package")
r <- df.pkg_downloads[J(pkg_list)]
r$count[is.na(r$count)] <- 1
saveRDS(r, "db.Rds")

library(XML)
rtime <- readHTMLTable("file:///var/folders/gg/g2b9zg5n59nb_93t3xnc8xtr0000gn/T/RtmpsRN8dd/filed5401e31b205.html", stringsAsFactors = FALSE)
rtime <- rtime[[1]]
rtime$Score <- as.integer(rtime$Score)
rtime[which(rtime$Score > 6),]
saveRDS(rtime, "posix.Rds")

pkg.log <- get_pkg_list("logging")
pkg.log.sc <- get_score(pkg.log)
saveRDS(tmp <- pkg.log.sc[which(pkg.log.sc > 10)], "log.Rds")
df.pkg_downloads[J(names(tmp))]

pkg.file <- get_pkg_list("file system")
pkg.file.sc <- get_score(pkg.file)
