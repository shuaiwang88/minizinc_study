% assignment 2
% select a set of raiding warrior
enum WARRIOR;
WARRIOR: dummy; 
enum CLAN; % the clan they belong too

int: l; % minimum raid party size
int: u; % maximum raid party size
int: m; % limit of hatreds

array[WARRIOR] of int: strength;
array[WARRIOR] of CLAN: clan;

array[CLAN,CLAN] of 0..1: hates;

% model 
var[l,u] of WARRIOR: raid;

constraint forall(i in 1..l)(raid[i] > dummy)


constraint sum(i, j in raid where i<j)(hates[clan[i], clan[j]]) <= m;

constraint not (dummy in raid);



var int: obj;
constraint obj = (sum(r in raid)(strength[r]));
solve maximize obj;

%array[1..n] of var OBJ: s;

