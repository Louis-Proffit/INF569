set B;	                # buses set
set L within {B,B};	# edges set

param root_bus;
param n default card(B);

param D{B};                             # demand 
param C{B} >= 0, default 0;                  # cost of generating power
param Gm{B} >= 0, default 0;                 # maximum generation
param Fm{L} >= 0, default sum{b in B} D[b];  # maximum flow at lines
param X{L} >= 0;                             # reactance

var theta{B};	                # the voltage can be positive, null, negative
var g{b in B} >= 0, <= Gm[b];   # generation
var f{L};                       # power flow at lines

minimize generation_cost:
  sum{b in B} C[b]*g[b]/1000;

subject to equilibrium{b in B}:
  sum{a in B: (a,b) in L} (-f[a,b]) + sum{a in B: (b,a) in L} f[b,a]
    = g[b] - D[b];
  
subject to flow_limit1{(b,a) in L}:
  f[b,a] <= Fm[b,a];

subject to flow_limit2{(b,a) in L}:
  -f[b,a] <= Fm[b,a];

subject to flow_def{(b,a) in L}:
  f[b,a] = (theta[b]-theta[a])/X[b,a];

subject to root:
  theta[root_bus] = 0;