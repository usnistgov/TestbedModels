% This script runs the NHR DC emulator model in conjunction with ICDAS
% by Allen Goldstein, NIST
% 8/11/2022
% Runs on MATLAB 2020b
%

%% Connect with the database
%conn = database('sgdb','postgres','SmartGrid2022','Vendor','POSTGRESQL','Server','NEMO.campus.NIST.GOV','PortNumber',5432);  % NEMO
conn = database('sgdb','postgres','smartgrid2022','Vendor','POSTGRESQL','Server','Helios','PortNumber',5432);  % Helios
 
%% Set simulation settings
%sample time
Ts = 1e-3;

%simulation duration; stop time
tFinal = 0.25; 

%% check for available settings
query = ['SELECT * ' ...
    'FROM sgdb.public.nhr_DC_icdas2model ' ...
    'ORDER BY data_id ASC ' ...
    'LIMIT 1'];

data_db2sim_check = fetch(conn,query);
