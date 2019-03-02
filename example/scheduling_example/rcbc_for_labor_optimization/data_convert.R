library(reticulate)

pybuiltins <- import_builtins()
a_set <- pybuiltins$set(list("black","red","green")) # for ennumerated sets

# create R object 
input_dzn <- list(
    a_param = 0.1,        # create scalar parameters
    b_list  = c(0,3,4,5),  # create 1 dimensional parametes
    array_2d= matrix(     # 2 dimensional array
               c(2, 4, 3, 1, 5, 7), 
               nrow=2,              
               ncol=3,             
               byrow = TRUE),      
    set = set_py 
               )

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

pymzn$dict2dzn(input_dzn, fout = "../../minizinc_labor/minizinc_labor/data_convert_data.dzn")



b = tuple(a = c(1,3,4)) 

v = list(bob=c(2, 3, 5), john=c("aa", "bb")) 
v

library(tidyverse)
schedule_map_data <- tibble(start = seq(5,12, by = 2),
                            end = seq(13, 20, by = 2))
schedule_map_data


pybuiltins <- import_builtins()
product_set <-  # for ennumerated sets




Products = { BananaCake, ChocolateCake };
profit = [400, 450]; % in cents
Resources = { Flour, Banana, Sugar, Butter, Cocoa };
capacity = [4000, 6, 2000, 500, 500];
consumption= [| 250, 2, 75, 100, 0,
              | 200, 0, 150, 150, 75 |];




