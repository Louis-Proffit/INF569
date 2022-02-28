
set T;
set J;
set W;

param c {J};
param cu {J};
param pl {J};
param pu {J};
param rUu {J};
param rDu {J};
param sUu {J};
param sDu {J};
param mUu {J};
param mDu {J};
param Dexp {T};
param D {T,W};
param pi {W};

var pf {J,T};
var pa {J,T,W};
var rU {J,T,W};
var rD {J,T,W};
var v {J,T} binary;
var y {J,T} binary;
var z {J,T} binary;

minimize cost:
	sum{t in T, j in J} (c[j] * pf[j,t] + cu[j] * y[j,t])
	+ sum {w in W, t in T, j in J} (pi[w] * c[j] * (rU[j,t,w] - rD[j,t,w]));
	
subject to start_stop {j in J, t in T: t > 1}:
	v[j,t-1] - v[j,t] + y[j,t] - z[j,t] = 0;
	
subject to local_generation_low {j in J, t in T}:
	pl[j] * v[j,t] <= pf[j,t];
	
subject to local_generation_high {j in J, t in T}:
	pu[j] * v[j,t] >= pf[j,t];
	
subject to global_generation {t in T}: 
	sum{j in J} pf[j,t] >= Dexp[t];

subject to link_first_second {t in T, w in W}: sum{j in J} pa[j,t,w] = D[t,w];

subject to ramp_up {j in J, t in T, w in W: t > 1}:
	pa[j,t,w] - pa[j,t-1,w] <= rUu[j] * v[j,t-1] + sUu[j] * y[j,t];
	
subject to ramp_down {j in J, t in T, w in W: t > 1}:
	pa[j,t-1,w] - pa[j,t,w] <= rDu[j] * v[j,t] + sDu[j] * z[j,t];
	
subject to local_generation_second_low {j in J, t in T, w in W} :
	pl[j] * v[j,t] <= pa[j,t,w];
	
subject to local_generation_second_high {j in J, t in T, w in W} :
	pu[j] * v[j,t] >= pa[j,t,w];

subject to reserve_up_up {j in J, t in T, w in W}:
	rU[j,t,w] <= mUu[j] * v[j,t];

subject to reserve_up_down {j in J, t in T, w in W}:
	0 <= rU[j,t,w];
	
subject to reserve_down_down {j in J, t in T, w in W}:
	0 <= rD[j,t,w];

subject to reserve_down_up {j in J, t in T, w in W}:
	rD[j,t,w] <= mDu[j] * v[j,t];