library("rcbc")

# max 1 * x + 2 * y
# s.t.
#   x + y <= 1
#   x, y binary
A <- matrix(c(1, 1), ncol = 2, nrow = 1)
A

result <- cbc_solve(
 obj = c(1, 2),
 mat = A, # <- can also be a sparse matrix
 is_integer = c(TRUE, TRUE),
 row_lb = -Inf, row_ub = 1, max = TRUE,
 col_lb = c(0, 0), col_ub = c(1, 1),
 cbc_args = list("SEC" = "1"))


############# knapsack problem ###########################
set.seed(1)
max_capacity <- 1000
n <- 100
weights <- round(runif(n, max = max_capacity))
weights
cost <- round(runif(n) * 100)

A <- matrix(weights, ncol = n, nrow = 1)
A

result <- cbc_solve(
 obj = cost,
 mat = A, 
 is_integer = rep.int(TRUE, n),
 row_lb = 0, row_ub = max_capacity, max = TRUE,
col_lb= rep.int(0, n), col_ub = rep.int(1, n))
