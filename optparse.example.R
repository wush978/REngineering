library(optparse)
opt <- parse_args(OptionParser(option_list=list(
  make_option("--C", default=1.0, help="The value of regularization parameter"),
  make_option("--NegSample", default=FALSE, help="Whether sample the negative data")
)))
