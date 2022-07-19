%% Set simulation settings
%sample time
Ts = 1e-3;

%simulation duration; stop time
tFinal = 5; 

%% setting model parameters
%Input panel
op_state = 2; %1: standby 2: charge 3: discharge 4: battery
Vmax_src = 480; %0-600V
Imax_src = 10; %0-(+40)A
Pmax_src = 8; %0-8kW
R_src = 0.001; %0-500 ohms
Vmin_snk = 20; %10-600V
Imax_snk = 40; % 0-(-40)A
Pmax_snk = 12; %0-12kW

%NHR 9200
turn_on = 1; % 1 or 0
slew_v = 200; %0.165-600V/ms
slew_i = 10; %0.011-40A/ms
slew_r = 400; %0.14-500 Ohms/ms
slew_p = 300; %2W-8kW/s

%safety settings:

Vmin_gb = -50;
t_Vmin_gb = 2;
Vmax_gb = 800;
t_Vmax_gb = 2;

Imax_snk_sfty = 80;
t_Imax_snk_sfty = 2;
Pmax_snk_sfty = 800;
t_Pmax_snk_sfty = 2;

Imax_src_sfty = 25;
t_Imax_src_sfty = 0.5;
Pmax_src_sfty = 5000;
t_Pmax_src_sfty = 2;

%battery detect:

v_bat = 0; %0 to disable

%% more settings
%common load for both source and sink mode
%nhrLoad = rand(1,1)*10+1.66;
nhrLoad = 15;

%battery for source mode
v_nom_bat_src = 20; %nominal voltage
r_bat_src = 2; %internal resistance

%battery for sink mode
v_nom_bat_snk = 300; %nominal voltage
r_bat_snk = 2; %internal resistance
%% running model
sim('NHR9200Model4960_prog.slx')