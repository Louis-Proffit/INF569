# Author: Louis Proffit
# Date: 20200106
# model.mod
model;

set BUSES ordered;
set GENERATORS within BUSES;
set LINES within (BUSES cross BUSES);

param D {BUSES} >= 0; # demand for each bus

param G {GENERATORS} >= 0; # Maximum production
param C {GENERATORS} >= 0; # cost of production

param F {LINES} >= 0; # maximum flow for line
param X {LINES} >= 0; # reactance of line

var z {GENERATORS} binary;
var theta {BUSES}; # voltage angle
var g {GENERATORS} >= 0; # produced power
var f {LINES}; # flow carried by line

minimize cost:
sum{j in GENERATORS} z[j];

subject to max_flow_constraint {(i,j) in LINES}: -F[i,j] <= f[i,j] <= F[i,j];

subject to angle_constraint {(i,j) in LINES}: f[i,j] = (theta[j] - theta[i]) / X[i,j];

subject to flow_constraint_generator {b in GENERATORS}: 
	sum{(b,a) in LINES} f[b,a]
		= g[b] - D[b];
		
subject to flow_constraint_non_generators {b in (BUSES diff GENERATORS)}: 
	sum{(b,a) in LINES} f[b,a]
		= - D[b];

subject to init_angle: theta[first(BUSES)] = 0;

subject to max_production_constraint_1 {i in GENERATORS}: 0 <= g[i] ;
subject to max_production_constraint_2 {i in GENERATORS}: g[i] - G[i] * z[i] <= 0;