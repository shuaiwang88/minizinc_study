orray[HEIGHT, WEIGHT] of var float: t; % temperature at point(i, j)
d
enum Products;  
% profit per unit for each product
array[Products] of int: profit;
% Resources to be used
enum Resources;
% amount of each resource available
array[Resources] of int: capacity; 

% units of each resource required to produce 1 unit of product
array[Products, Resources] of int: consumption; 
constraint assert(forall (r in Resources, p in Products) 
           (consumption[p,r] >= 0), "Error: negative consumption");

% bound on number of Products
int: mproducts = max (p in Products) 
                     (min (r in Resources where consumption[p,r] > 0) 
                          (capacity[r] div consumption[p,r]));

% Variables: how much should we make of each product
array[Products] of var 0..mproducts: produce;
array[Resources] of var 0..max(capacity): used;

% Production cannot use more than the available Resources:
constraint forall (r in Resources) (     
      used[r] = sum (p in Products)(consumption[p, r] * produce[p]) 
);
constraint forall (r in Resources) (     
      used[r] <= capacity[r]
);    

% Maximize profit
solve maximize sum (p in Products) (profit[p]*produce[p]);

output [ "\(p) = \(produce[p]);\n" | p in Products ] ++
       [ "\(r) = \(used[r]);\n" | r in Resources ];1[HEIGHT, WEIGHT] of var float: t; % temperature at point(i, j)

% % Laplace equation: each internal temp. is average of its neighbours
% constraint forall(i in CHEIGHT, j in CWIDTH)(
%               4.0*t[i,j] = t[i-1,j] + t[i,j-1] + t[i+1,j] + t[i,j+1]);
  
% /* ensures that each internal point (i,j) is the average of its four orthogonal */
% /* neighbours. The constraints */

% % edge constraints
% constraint forall(i in CHEIGHT)(t[i,0] = left);
% constraint forall(i in CHEIGHT)(t[i,w] = right);
% constraint forall(j in CWIDTH)(t[0,j] = top);
% constraint forall(j in CWIDTH)(t[h,j] = bottom);

% /* restrict the temperatures on each edge to be equal, and gives these */
% /* temperatures names: left, right, top and bottom. While the constraints */

% constraint t[0,0] = 0.0;
% constraint t[0,w] = 0.0;
% constraint t[h,0] = 0.0;
% constraint t[h,w] = 0.0;


% % Laplace equation: each internal temp. is average of its neighbours
% constraint forall(i in CHEIGHT, j in CWIDTH)(
%               4.0*t[i,j] = t[i-1,j] + t[i,j-1] + t[i+1,j] + t[i,j+1]);
  
% /* ensures that each internal point (i,j) is the average of its four orthogonal */
% /* neighbours. The constraints */

% % edge constraints
% constraint forall(i in CHEIGHT)(t[i,0] = left);
% constraint forall(i in CHEIGHT)(t[i,w] = right);
% constraint forall(j in CWIDTH)(t[0,j] = top);
% constraint forall(j in CWIDTH)(t[h,j] = bottom);

% /* restrict the temperatures on each edge to be equal, and gives these */
% /* temperatures names: left, right, top and bottom. While the constraints */

% constraint t[0,0] = 0.0;
% constraint t[0,w] = 0.0;
% constraint t[h,0] = 0.0;
% constraint t[h,w] = 0.0;


