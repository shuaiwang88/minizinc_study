constraint forall (r in Resources) (
used[r] = sum (p in Products)(consumption[p, r] * produce[p])
);

constraint forall ([ x[i] != x[j] | i,j in 1..n where i<j ]);

constraint forall(i in 0..n-1) (
s[i] = (sum(j in 0..n-1)(bool2int(s[j]=i))));

var int: obj = sum(i,j in NUM where i < j)(dist[i,j]);

/\ : and 
\/: or 
constraint forall(j in DAY)(
sum(i in NURSE)(roster[i,j] == d) == req_day /\
sum(i in NURSE)(roster[i,j] == n) == req_night
);

[f(i, j) | i in A1 where p(i), j in A2 where q(i,j)]

{ 3*i+j | i in 0..2, j in {0, 1} } % { 0, 1, 3, 4, 6, 7 }

constraint
    forall (R in region) (
        sum (r in ROW, c in COL) (bool2int(grid[r, c] = R))  =  region_size[R]
    );


constraint forall(i in CHEIGHT, j in CWIDTH)(
4.0*t[i,j] = t[i-1,j] + t[i,j-1] + t[i+1,j] + t[i,j+1]);

forall( [a[i] != a[j] | i,j in 1..3 where i < j]) # good
forall (i,j in 1..3 where i < j) (a[i] != a[j])   # better

constraint
    forall (R1, R2 in region
            where R1 < R2 /\ region_size[R1] = region_size[R2]) (
        forall (r in ROW, c in COL) (
            exclude_neighbours(r, c, r + 1, c, R1, R2)
        /\  exclude_neighbours(r, c, r, c + 1, R1, R2)
        )
    );


constraint
    forall (R in region) (
        sum (r in ROW, c in COL) (bool2int(grid[r, c] = R))  =  region_size[R]
    );


constraint forall (r in Re/sources)
(used[r] = sum (p in Products) (consumption[p, r] * produce[p]));


constraint forall (i in PuzzleRange) (
alldifferent( [ puzzle[i,j] | j in PuzzleRange ]) );


constraint %% ensure the tasks occur in sequence
forall(i in JOB) (
forall(j in TASK where j < last)
(s[i,j] + d[i,j] <= s[i,enum_next(TASK,j)]) /\
s[i,last] + d[i,last] <= end
);

constraint %% ensure no overlap of tasks
forall(j in TASK) (
forall(i,k in JOB where i < k) (
s[i,j] + d[i,j] <= s[k,j] \/
s[k,j] + d[k,j] <= s[i,j]
)
);

constraint forall(i in 0..n-1) (
s[i] = (sum(j in 0..n-1)(bool2int(s[j]=i))));


