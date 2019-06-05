library(tidyverse)
library(jsonlite)
library(glue)

to_enum <- function(x) {
  # maybe put in error handling if needs to be character
  # { BananaCake, ChocolateCake }
  sprintf("{%s}", glue_collapse(x, ","))
}


bb <- to_enum(c("a", "n"))


to_array <- function(x) {
  stopifnot(is.numeric(x))
  # profit = [400, 450]
  sprintf("[%s]", glue_collapse(x, ","))
}
to_array(4)
to_array(c(1,3))


to_matrix <- function(x) {
  # matrix = [| 250, 2, 75, 100, 0,
  #           | 200, 0, 150, 150, 75 |]
  stopifnot(is.matrix(x))
  make_row <- function(x) paste0("|", glue_collapse(x, sep = ","))
  rows     <- apply(x, 1, make_row)
  sprintf("[%s|]", glue_collapse(rows, sep = ",\n"))
}
to_matrix(matrix(data = seq(1,10),
                 nrow = 5))

solve_mz <- function(model, data = NULL, solver = "osicbc") {

  # args:
  #   model - char; an mzn specification
  #   data  - chart; a dzn specification
  #   solver - one of osicbc, ...
  #
  # returns: a json
  
  model_file <- tempfile(fileext = ".mzn")
  write_file(model, model_file)
  
  # Optionally use data file
  if (!is.null(data)) {
    data_file <- tempfile(fileext = ".dzn")
    write_file(data, data_file)
  } else {
    data_file <- ""
  }
  
  # Call command line solver
  # cmd <- "/home/kon6750/software/MiniZincIDE-2.2.3-bundle-linux/bin/minizinc --solver {solver} --output-mode json {model_file} {data_file}"
  cmd <- "minizinc --solver {solver} --time-limit 60000 --output-mode  json {model_file} {data_file}"
  res <- system(glue(cmd), intern = TRUE)
  
  # Minizinc communicates exit status by appending messages in equal singns...
  # https://www.minizinc.org/doc-2.2.3/en/spec.html#output
  
  # A status line (supposedly) comes at the very end
  last   <- tail(res, 1)
  status <- switch(
    last,
    "=========="                 = "optimal",
    "=====UNSATISFIABLE====="    = "unsatisfiable",
    "=====UNBOUNDED====="        = "unbounded",
    "=====UNSATorUNBOUNDED=====" = "unsat_or_unbounded",
    "=====UNKNOWN====="          = "unknown",
    "=====ERROR====="            = "error",
    NA)
  
  # Drop the status line after parsing the status
  if (!is.na(status)) res <- head(res, -1)
  
  # Format solutions as valid json and and parse
  # Note: Solutions are end-delimited by 10 dashes
  soln_mark <- "----------"
  any_soln  <- any(res == soln_mark)
  if (any_soln) {
    # res <- c(res, res)  # FOR TESTING MULTIPLE SOLUTIONS
    # Format solutions as json list
    res <- glue_collapse(res) %>% 
      str_split(., soln_mark) %>% 
      unlist(.) %>% 
      Filter(function(x) x != "", .)
    
    # If multiple solutions, make a list of dicts
    if (length(res) > 1) res <- sprintf("[%s]", glue_collapse(res, sep = ","))
    soln <- fromJSON(res, simplifyDataFrame = FALSE)
    
  } else {
    soln <- NA
  }
  list(solution = soln, status = status)
}

# MAIN
# dzn <- read_file("~/Desktop/data.dzn")
# shifts      <- c("f0412", "f0614")
# capacity    <- c(4000, 6, 2000, 500, 500)
# consumption <- matrix(c(250, 2, 75, 100, 0,
#                         200, 0, 150, 150, 75),
#                       nrow = 2, byrow = TRUE)


# Toy example testing commandline functionality
# mzn <- read_file("../../jobshop.mzn")
# # dzn_name <- tempfile(fileext = ".dzn")
# # dzn <- read_file(dzn_name)
# dzn <- read_file("../../jdata.dzn")
# 
# d_matrix <- matrix(c(10, 4, 5, 3, 6,
#                      3, 2, 7, 1, 2,
#                      4, 4, 4, 4, 4,
#                      1, 1, 1, 6, 8,
#                      7, 3, 2, 2, 1),
#                    nrow = 5, byrow = TRUE)
# 
# d_matrix <- to_matrix(d_matrix)
# 
# dzn <- glue(dzn)
# 
# # 
# # mzn <- read_file("minizinc.mzn")
# # dzn <- read_file("minizinc-data.dzn")
# # 
# res <- solve_mz(mzn, dzn)

# print(res)
# 
# mzn <- read_file("~/Downloads/jobshop.mzn")
# dzn <- read_file("~/Downloads/jdata.dzn")
# 
# d_matrix <- matrix(c(1, 4, 5, 3, 6,
#                      3, 2, 7, 1, 2,
#                      4, 4, 4, 4, 4, 
#                      1, 1, 1, 6, 8,
#                      7, 3, 2, 2, 1),
#                    nrow = 5, byrow = TRUE)
# 
# d_matrix <- to_matrix(d_matrix)
# 
# dzn <- glue(dzn)
# res <- solve_mz(mzn, dzn)
# print(res)
