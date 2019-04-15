source("mzr.R")
source("labor_functions.R")
# MAIN
# dzn <- read_file("~/Desktop/data.dzn")

CONF_LOC   <- "store_configs.csv"

configs <- read_csv(CONF_LOC, col_types = "cciiTiiiiii")

shifts <- list(
  full_time  = list(start_range = c(configs$full_pick_start_hour,
                                    configs$full_pick_end_hour),
                    duration = configs$full_shift1_len),
  part_time1 = list(start_range = c(configs$part_pick_start_hour,
                                    configs$park_pick_end_hour),
                    duration = configs$part_shift1_len)
  )

gen_shifts_matrix <- function(def) {
  f <- function(x, dur) between(1:24, x, x + dur) %>% as.integer() 
  full_seq(def$start_range, 1) %>% 
    sapply(., f, def$duration) %>% 
    t(.)
}



############# #################################################
#                  Generate input for minizinc                #
FULL_str <- "F"
PART_str <- "P"


shifts_mat <- map(shifts, gen_shifts_matrix)
ShiftMap   <- reduce(shifts_mat, rbind)     # collapsed matrix

ShiftSet <- rownames(ShiftMap)
ShiftMap_LEN <- rowSums(ShiftMap)

demand <- read_csv("demand_minizinc_2019_03_06.csv") %>%
  data.matrix() 

PickWindow <- c(5,3,3,3) 


mzn <- read_file("minizinc_labor_model.mzn")

dzn <- read_file("minizinc_labor_data_template.dzn")


dzn <- glue(dzn)

res <- solve_mz(mzn, dzn)

pickScheduling <- res[['solution']][["PickScheduling"]]
pickScheduling

