%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clicklist Labor Optmization Model.
% Author:
%   Model: Xinhui.Zhang, Isaac Hampton
%   Implementation: Shuai Wang (Minizinc), Eugene Pyatigorsky (Data processing)
%
% Goal: create daily staffing plan for clicklist picker. 
% Reqiurement: 
%   1. Forcasting of labor hours by hour and zone. 
%   2. Pre-configured shift plan with start and end hour. Eg, full time shift
%      start from 5 to 12.
%   3. Parameters like #zones,#leadtime
%
% Output:
%   How many pickers needed for each shift plan.
%
% Todo: 
%   1. individual level weekly plan:
% stackoverflow.com/questions/48278879/minizinc-array-of-multidimensional-array
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Define sets
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/* 1. set of time in hour and day */    
%  s, t	index of hour set T, where T = {1,.,24}
set of int:  Hour = 1..24;

/* d is the index of set Day or D, where D = {1,.,7} */
set of int: Day = 1..7;

/* 2. temperature zone set */  
% k	index of zone set K, where K = {1,.,4} {Ambient, Deli, Frozen, Refrigerated}
set of int:  Zone = 1..4;

/* 3. schedule set */            
% Index of shift set F, {f412, f513, f614, f715, p1620…}
% can be 8 hours full shift, and part time shift like 6, 4 hours 
% defined as a enumerated set in .dzn file and this can be store dependdent.
enum ShiftSet;

/* 4. picker set */
enum PickerSet;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Define picking parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/* 1. TS(k): Time allowed to Start picking */
% maximum hours allowed to start picking before the delivery time of 
% orders due to exposure to room temperature. eg, frozen order, 5 hours 
% [5,3,3,3]
array[Zone] of float: Window_Start;

/* 2. TE(k): Time allowed to End picking */
% minimum hour allowed to finish picking before the delivery time of
% orders due to time of a picking tour, say 2  --was not indexed by k before 
int: Window_End;

%   <-----------------------Window_Start ------------------------>
%   |                                                            |
%   |                                       <--   Window_End  -->|
%   |                                       |                    |
%   .------------------------------------------------------------.
%   |                                       |                  delivery
%   <~~~~~~~  allowed picking window   ~~~~~>                  hour


/* 3. O(max): maximum picking hours allowed temporary staff for any hour period –not used */
int: Max_Temp_Pickers = 2;

/* 4. a) D(tk): demand in the number of hours of picking labor to be picked by at time t in zone k 
      b) A(t):  demand in the number of attending hours required in hour t*/ 
array[Hour, Zone] of float: Demand;
array[Hour] of float: Attending;

/* 5. L(f): shift length in hour for each shift f belongs to F */
array[ShiftSet] of float: Shift_Len;

/* 6. A(ft): 0-1 Matrix representation of set F */
/* array[ShiftSet, Hour] of int: Shift_Map; */
array[PickerSet, Day, ShifSet, Hour] of int: Shift_Map;

/* 7. ratio of full time to part time */
float: Ratio_Full_to_Part = 3;

/* 8. theshhold of part time hour */
int: Hour_Part = 6;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Define penalty parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
/* 1. pk: the number of item units that an picker can pick in zone k per time */
% period –not used
%array[Zone] of int: picking_num_by_zone;

/* 2. α: penalty coefficient on inventory per unit (order) per time period */  
float: penalty_inventory  = 0.1;

/* 3. β: penalty coefficient on using temporary pickers per person per time period */ 
float: penalty_temp_picker = 10 ;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Define Variables 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/* 1. P(stk): the number of regular picking hours required at time s to satisfy */
/* demand in delivery time t in zone k */
float: Max_Pick_per_Hour = 1000.0; % upbound and it's a float
array[Hour, Zone, Hour] of var 0..Max_Pick_per_Hour: PickScheduling;


/* 2. O(stk): the number of overtime picking labor hours required at time s to */
/* satisfy demand in delivery time t in zone k */ 

array[Hour, Zone, Hour] of var 0..Max_Pick_per_Hour: OverPickScheduling;

/* 3. X(f): the number of pickers assigned to shift f */  
/* int: Max_Picker_per_Hour = 100; */
/* array[ShiftSet] of var 0..Max_Picker_per_Hour: Shift_Assign; */

/* 3. 3darray X(p,d,f) whether to assign the shift to picker on day with shift asked. */
array[PickerSet, Day, ShiftSet] of var bool: Shift_Assign;

/* 4.  I(tk): the number of inventory (in orders) in zone k at in delivery time t. */ 
% not used
% The total Inventory generated by two tpyes of picking activities.
% s is the picking time and t is the deliver time.
% where i is Inventory between s and t.

% var float: Inventory[i in Hour, Zone] = 
%        sum([PickScheduling[s in Hour,k in Zone, t in Hour] + 
%		 OverPickScheduling[s in in Hour,k in Zone, t in Hour] | i in s..t]);

% array comprehension.
% forall( [a[i] != a[j] | i,j in 1..3 where i < j]) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Define Objective 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Minimize: number of picker used + penalty on temporary pickers + penalty on invertory
/* var float: objective = */ 
/*   sum(f in ShiftSet)(Shift_Assign[f] * Shift_Len[f]) + */
/*   penalty_temp_picker * sum(s in Hour, k in Zone, t in Hour)(OverPickScheduling[s,k,t]); */
%   + penalty_inventory * sum(k in Zone, i in Hour)(Inventory[k,i]); % not used


var float: objective = 
  sum(p in PickerSet, d in Day, f in ShiftSet)
            (Shift_Assign[p,d,f] * Shift_Len[f]) +
  penalty_temp_picker * sum(s in Hour, k in Zone, t in Hour)(OverPickScheduling[s,k,t]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%           Define Constraints 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

/* 1. limit the available permanent picker in any hour period to the */
%  number of pickers scheduled
% ∑(t≥s+1)∑(k in K) P_stk ≤  ∑(f in F)(A(f,t) * Xf)  for all s in T
float: Picking_Efficiency;

/* constraint */
/* forall(s in Hour) ( */
/*    sum(k in Zone, t in Hour ) %where t >= s+ 1) */
/*       (PickScheduling[s,k,t]) / Picking_Efficiency + Attending[s] <= */ 
/*         sum(f in ShiftSet)(Shift_Map[f,s] * Shift_Assign[f])); */


/* 1. limit the available permanent picker in any hour period to the */
%  number of pickers scheduled
% ∑(t≥s+1)∑(k in K) P_stk ≤  ∑(p in P, f in F)(A(p,d,f,s) * X(p,d,f)) 
%                                              for all d in Day, s in Hour
constraint
forall(d in Day, s in Hour) (
   sum(t in hour, k in zone) 
      (pickscheduling[s,k,t]) / picking_efficiency + attending[s] <= 
        sum(p in PickerSet, f in shiftset)(
                            shift_map[p,d,f,s] * shift_assign[p,d,f]));

/* 2. limit the number of temperary pickers --not active */
% ∑(t=s+1)∑(k in k) o_stk ≤ o(max)    for all s in t 
constraint
forall(s in hour) (
   sum(k in zone, t in hour where t >= s+ 1)(overpickscheduling[s,k,t]) <= 
   Max_Temp_Pickers);
  

% /* Only picking forward in time */
% constraint forall(s in Hour, k in Zone, t in Hour where t <= s)
%   (PickScheduling[s, k, t] = 0);


/* 3. Demand satisfication */

%todo any changes to the demand to 7 * 24? 

% IndexDomain: (t,k);
% Definition: 
% sum(s | (s < t) and (s >= (t - Window_Start(k))), 
% PickScheduling(s,k,t) + OverPickScheduling(s,k,t)) >= Demand(t, k);
% /\ and 
% \/ or 

constraint 
forall(t in Hour, k in Zone) (
   sum(s in Hour where s >= (t - Window_Start[k]) /\ s <= (t - Window_End))
  (PickScheduling[s,k,t] + OverPickScheduling[s,k,t]) = Demand[t,k]
);


/* 4. Limit part-time shifts */
% ∑(f in F|L(f)≤6) X(f) ≤  Ratio_Part_to_Full*∑(f in F|L(f)>6)X(f)    

/* constraint */
/* sum(f in ShiftSet where Shift_Len[f] > Hour_Part) */
/*    (Shift_Assign[f]) >= */ 
/*    Ratio_Full_to_Part*sum(f in ShiftSet where Shift_Len[f] <= Hour_Part) */
/*    (Shift_Assign[f]); */


/* 4. Limit part-time shifts */
∑(p in PickerSet, f in F|L(f)≤6) X(p,d,f) ≤
                Ratio_Part_to_Full*∑(p in PickerSet, f in F|L(f)>6)X(p,d,f)    

constraint
sum(p in PickerSet, f in ShiftSet where Shift_Len[f] > Hour_Part)
   (Shift_Assign[p,d,f]) >= 
  Ratio_Full_to_Part*
sum(p in PickerSet, f in ShiftSet where Shift_Len[f] <= Hour_Part)
   (Shift_Assign[p,d,f]);
/* 4b. Non-loitering */
%constraint forall(f in ShiftSet, s in Hour diff {1} where Shift_Assign[f] > 0)(
%   Shift_Map[f, s] > Shift_Map[f, s-1] -> 
%     sum(t in Hour, k in Zone)(PickScheduling[s,k,t]) + Attending[s] > 0);
 
 array[ShiftSet] of int: 
   ShiftStart = [min([i | i in Hour where Shift_Map[f, i] = 1]) | f in ShiftSet];
 
 constraint forall(f in ShiftSet where Shift_Assign[f] > 0)(
   sum(k in Zone, t in Hour)(PickScheduling[ShiftStart[f], k, t]) + 
                             Attending[ShiftStart[f]] > 0);
 
 
%  constraint forall(f in ShiftSet, s in Hour diff {1} where Shift_Assign[f] > 0)(
%   (Shift_Map[f, s] > Shift_Map[f, s-1]) -> 
%     sum(t in Hour, k in Zone)(PickScheduling[s,k,t]) + Attending[s] > 0);
 
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%            Solve and Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

solve minimize objective;
output ["Objective: "++show(objective) ++ "\n" ++
        "number of pickers required by each shift:" ++ "\n" ++ 
        show(Shift_Assign) ];

output [ "\n" ++
        "\(f) = \(Shift_Assign[f]);" | f in ShiftSet];

output [show(ShiftStart)];
% output [ objective];
% output [show(PickScheduling)];
