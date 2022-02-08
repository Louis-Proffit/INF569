# Author: Louis Proffit
# Date: 20200106
# model.mod
model;

param T integer >2;
param N integer >0;

set periods ordered:= {1..T};
set units:= {1..N};

param unit_power_price{periods};
param turbine_startup_cost{units};
param pump_startup_cost{units};
param pump_energy_startup_cost{units};

param initial_turbine_status{units};
param initial_pump_status{units};

param min_flow{units} >0;
param max_flow{units} >0;
param initial_flow{units};
param max_pump_flow{units}<0;

param min_power {units} <0;
param max_power {units};
# param initial_power {units};
param max_ramp_down;
param max_ramp_up;

param min_volume;
param max_volume;
param target_volume;
param initial_volume;
param tau;
param water_inflow {periods};

param max_water_spillage;
param Theta;
param W {units};
param Y {units};

var turbine_status {units,periods} binary;
var pump_status {units,periods} binary;
var turbine_start {units,periods} binary;
var turbine_shutdown {units,periods} binary;
var pump_start {units,periods} binary;
var pump_shutdown {units,periods} binary;

var flow {units, periods};
var power {units, periods};
var volume {periods};
var spillage {periods};

maximize profit :
sum{(i,t) in {units, periods}} 
(
	tau * unit_power_price[t] * power[i,t] - 
	turbine_startup_cost[i] * turbine_start[i,t] - 
	(pump_startup_cost[i] + pump_energy_startup_cost[i] * unit_power_price[t]) * pump_start[i,t]
);

subject to initial_turbine{i in units}:turbine_status[i,1]=initial_turbine_status[i];

subject to initial_pump {i in units}:pump_status[i,1]=initial_pump_status[i];
subject to turbine_or_pump {(i,t) in {units, periods}}:pump_status[i,t] + turbine_status[i,t]<=1;
subject to not_all_pumps {t in periods}:sum {i in units} pump_status[i,t] <= N-1;


subject to _0 {(i,t) in {units, periods}}:turbine_start[i,t] + turbine_shutdown[i,t]<=1;
subject to _1 {(i,t) in {units, {2..T}}}:turbine_status[i,t] - turbine_status[i,t-1]-(turbine_start[i,t] - turbine_shutdown[i,t])=0;

subject to _2 {(i,t) in {units, periods}}:pump_start[i,t] + pump_shutdown[i,t]<=1;
subject to _3 {(i,t) in {units, {2..T}}}:pump_status[i,t] - pump_status[i,t-1]-(pump_start[i,t] - pump_shutdown[i,t])=0;

subject to flow_bounds {(i,t) in {units, periods}}:min_flow[i]<=flow[i,t]<=max_flow[i];
subject to initial_flow_c {i in units}:flow[i,1]=initial_flow[i];
subject to _4 {(i,t) in {units, periods}}:max_pump_flow[i] * pump_status[i,t] + min_flow[i] * turbine_status[i,t]<=flow[i,t];
subject to _5 {(i,t) in {units, periods}}:max_pump_flow[i] * pump_status[i,t] + max_flow[i] * turbine_status[i,t]>=flow[i,t];

subject to power_bounds {(i,t) in {units, periods}}:min_power[i]<=power[i,t]<=max_power[i];
# subject to initial_power_c {i in units}:power[i,1]=initial_power[i];
subject to ramping_constraints {t in {2..T}}:-max_ramp_down<=sum {i in units} (power[i,t] - power[i,t-1])<=max_ramp_up;

subject to volume_bounds {t in periods}:min_volume<=volume[t]<=max_volume;
subject to initial_volume_c : volume[first(periods)]=initial_volume;
subject to final_volume_c : volume[last(periods)]=target_volume;
subject to water_conservation {t in {2..T}}:volume[t]=volume[t-1]+3600*tau*(water_inflow[t] - (sum {i in units} power[i,t]) - spillage[t]);

subject to spillage_bounds {t in periods}:0<=spillage[t]<=max_water_spillage;
subject to _6 {t in periods}:(sum {i in units} flow[i,t]) + spillage[t] - Theta >=0;
subject to _7 {t in periods}:spillage[t] - sum {i in units} (W[i] * turbine_start[i,t] + Y[i] * pump_start[i,t]) >= 0;

subject to _dommy_power {(i,t) in {units,periods}}: power[i,t] = 9.81 / 1000 * flow[i,t];








