
param C >0;

set V ordered;
set T ordered;

param x_coord {V};
param y_coord {V};
param type {V};

param k {T};
param u {T};
param max_usage {T};

param c {(i,j,t) in {V,V,T}} = u[t] * sqrt((x_coord[j] - x_coord[i]) ** 2 + (y_coord[j] - y_coord[i]) ** 2);

var x {V,V,T} binary;
var y {V,V} binary;
var f {V,V} >= 0;

minimize cost:
	sum {(i,j,t) in {V,V,T}} (c[i,j,t] * x[i,j,t]);
	
subject to complete_constraint {(i,j) in {V,V}}:sum {t in T} x[i,j,t] = y[i,j];

subject to type_agglomerate {(i,j) in {V,V}}: sum{t in T} x[i,j,t] = y[i,j];

subject to flow_conservation_turbines {i in V : type[i]>0}: sum{j in V : j!=i} (f[i,j] - f[j,i]) = 1;

subject to max_flow_constraint {(i,j) in {V,V}}:sum{t in T} (k[t] * x[i,j,t]) >= f[i,j];

subject to turbine_single_out_only {i in V:type[i]>0}:sum{j in V:j!=i} y[i,j]=1;

subject to none_out_of_sst {i in V:type[i]<0}:sum{j in V:j!=i} y[i,j]=0;

subject to max_number_of_cable_out_of_sst {i in V:type[i]<0}:sum{j in V:j!=i} y[i,j]<=C;


