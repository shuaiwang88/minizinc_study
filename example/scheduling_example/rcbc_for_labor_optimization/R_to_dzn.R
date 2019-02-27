library(reticulate)

pybuiltins <- import_builtins()
a_set <- pybuiltins$set(list("black","red","green")) # for ennumerated sets

# create R object 
input_dzn <- list(
   Products  = pybuiltins$set(list("BananaCake","ChocolateCake")),
   profit    = as.integer(c(400,450)),
   Resources = pybuiltins$set(list("Flour", "Banana", "Sugar", "Butter", "Cocoa")),
   capacity  = as.integer(c(4000, 6, 2000, 500, 500)),
   consumption = matrix(c(250, 2, 75, 100,0,
                          200, 0, 150, 150, 75), nrow = 2)
   
)
# Convert R object to python object
input_dzn <- r_to_py(input_dzn)

# load pymzn library from pythobn into R 
pymzn = import("pymzn")

pymzn$dict2dzn(input_dzn, fout = "../../minizinc_labor/minizinc_labor/data_convert_data.dzn")
d
