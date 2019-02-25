% A banana cake which takes 250g of self-raising flour, 2 mashed bananas, 75g
% sugar and 100g of butter, and a chocolate cake which takes 200g of
% self-raising flour, 75g of cocoa, 150g sugar and 150g of butter. We can sell
% a chocolate cake for $4.50 and a banana cake for $4.00. And we have 4kg
% self-raising flour, 6 bananas, 2kg of sugar, 500g of butter and 500g of
% cocoa. The question is how many of each sort of cake should we bake for the
% fete to maximise the profit. 


% Define Set ----
% 1. products
enum Products;

% 2. Resources
enum Resource;

% Define Parameters ----

array [Products] of int: profit;
array [Products, Resources] of int: consumption;
array [Resources] of int: capacity;

% Define Variables: how much each sort of cake should we bake
array[Products] of var 0..10: produce;
/* arrary[Resources] of var 0..max(capacity): used; */

% Define objective
% profit of produce has max value
%max[ sum(profit(p)* produce[p]), for all p] 
solve maximize sum(p in Products) (profit[p] * produce[p]);

% Define Constraints:
% 1. Sum(p, consumption(p,r) * produce(p) <= capacity(r))  for every r 

constraint forall (r in Resources)(
    sum(p in Products) (consumption[p,r] * produce[p] <= capacity[r])
);


output [ "\(p) = \(produce[p]);\n" | p in Products ] ++                            │ 13 % Define objective                                                              
       [ "\(r) = \(used[r]);\n" | r in Resources ];     
