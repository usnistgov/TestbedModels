%% This script runs chroma LPS model programmatically
% Written at NIST Smart Grid on 27-Apr-2022
% This code is written in MATLAB Version 9.9 (R2020b) and Database Toolbox Version 10.0 
% Last updated on 23-Jun-2022

%% Clear the workspace
%clear
%clc
%close all

%% connect with database
%conn = database('sgdb','postgres','SmartGrid2022','Vendor','POSTGRESQL','Server','NEMO.campus.NIST.GOV','PortNumber',5432);
%conn = database('sgdb','postgres','SmartGrid2022','Vendor','POSTGRESQL','Server','129.6.32.139','PortNumber',5432);
conn = database('sgdb','postgres','smartgrid2022','Vendor','POSTGRESQL','Server','Helios','PortNumber',5432);
%disp('Connection with database is successful!')

%% Set simulation settings
%sample time
Ts = 1e-3;

%simulation duration; stop time
tFinal = 0.25; 


%% (optional) Read data table icdas2model 
%conn = database('sgdb','postgres','SmartGrid2022','Vendor','POSTGRESQL','Server','NEMO.campus.NIST.GOV','PortNumber',5432);

%data_db2sim = sqlread(conn, "chroma_ps_icdas2model");

%% check for available settings
query = ['SELECT * ' ...
    'FROM sgdb.public.chroma_ps_icdas2model ' ...
    'ORDER BY data_id ASC ' ...
    'LIMIT 1'];

data_db2sim_check = fetch(conn,query);

%% Run simulation

%waitbar
hWaitbar = waitbar(0, 'Simulation 1', 'Name', 'ICDAS<>SIMULINK','CreateCancelBtn','delete(gcbf)');

while 1
    
    if isempty(data_db2sim_check.data_id) == 1
        disp('There is no settings available in the database. Aborting simulation...');
        break;
    else
        disp('Transferring settings from database to Matlab...');
        query = ['SELECT * ' ...
            'FROM sgdb.public.chroma_ps_icdas2model ' ...
            'WHERE read_by_model = false ' ...
            'ORDER BY data_id ASC ' ...
            'LIMIT 1'];

        data = fetch(conn,query);
        disp('Reading from icdas2model is successful!')
    
        dID = data.data_id;
    
        % draw the progress bar
        drawnow;
        if ~ishandle(hWaitbar)
            % Stop the if cancel button was pressed
            disp('Stopped by user');
            break;
        else
            % Update the wait bar
            i=dID;
            waitbar(1,hWaitbar, ['Simulation for data id:  ' num2str(i)]);
        end
    
        %run last settings if no new settings from ICDAS
        if isempty(dID) == 1
            disp('last test settings is reached!')
            query = ['SELECT * ' ...
                'FROM sgdb.public.chroma_ps_icdas2model ' ...
                'WHERE read_by_model = true ' ...
                'ORDER BY data_id DESC ' ...
                'LIMIT 1'];
            data_last = fetch(conn,query);
         
            op_mode = data.output_mode;
            I_set = data_last.current;
            I_min = data_last.current_limit_low;
            I_max = data_last.current_limit_high;
            I_prot = data_last.current_protect;
            I_slew = data_last.current_slew;
            V_set = data_last.voltage;
            V_min = data_last.voltage_limit_low;
            V_max = data_last.voltage_limit_high;
            V_prot = data_last.voltage_protect;
            V_slew = data_last.voltage_slew;
            P_prot = data_last.power_protect;
    
            while 1
                TestLoad = rand(1,1)*5+1.66;
                sim('ChromaLPS_vX.slx')
                voltage = voltageOut.data(end, :);
                current = currentOut.data(end, :);
                power = powerOut.data(end, :);
                time = datetime('now','Format','yyyy-MM-dd HH:mm:ss.S' );
                data_mes = table(voltage,current,power,time,time,...
                    'VariableNames',["voltage" "current" "power" "meas_timestamp" "write_timestamp"]);
    
                tablename = "chroma_ps_model2icdas";
                sqlwrite(conn,tablename,data_mes)

                disp('Output data for last setting write to server is successful!')
            
                query = ['SELECT * ' ...
                    'FROM sgdb.public.chroma_ps_icdas2model ' ...
                    'WHERE read_by_model = false ' ...
                    'ORDER BY data_id ASC ' ...
                    'LIMIT 1'];

                data = fetch(conn,query);
                disp('Reading from icdas2model is successful!')
    
                dID = data.data_id;
            
                % draw the progress bar
                if ~ishandle(hWaitbar)
                    % Stop the if cancel button was pressed
                    disp('Stopped by user');
                    break;
                else
                    % Update the wait bar
                i=data_last.data_id;
                waitbar(1,hWaitbar, ['Simulation for data id (last settings):  ' num2str(i)]);
                end
            
                if isempty(dID) == 0
                    break
                end
            end
       % break
    end
    
    
    colnames = {'read_by_model','read_timestamp'};

    readTime = datetime('now','Format','yyyy-MM-dd HH:mm:ss.S' );
    newData = {'true',datestr(readTime,31)};

    tablename = 'chroma_ps_icdas2model';
    whereclause = ['WHERE data_id ='  num2str(data.data_id)]; 
    
    update(conn,tablename,colnames,newData,whereclause) 

    disp('icdas2model update with read receipt and read timestamp is successful!')

    op_mode = data.output_mode;
    I_set = data.current;
    I_min = data.current_limit_low;
    I_max = data.current_limit_high;
    I_prot = data.current_protect;
    I_slew = data.current_slew;
    V_set = data.voltage;
    V_min = data.voltage_limit_low;
    V_max = data.voltage_limit_high;
    V_prot = data.voltage_protect;
    V_slew = data.voltage_slew;
    P_prot = data.power_protect;

    disp(['Simulink settings are exported to Matlab workspace for data_id = ',num2str(data.data_id)])
    
    TestLoad = rand(1,1)*5+1.66
    sim('ChromaLPS_vX.slx')
    
    voltage = voltageOut.data(end, :);
    current = currentOut.data(end, :);
    power = powerOut.data(end, :);
    time = datetime('now','Format','yyyy-MM-dd HH:mm:ss.S' );
    data_mes = table(voltage,current,power,time,time,...
        'VariableNames',["voltage" "current" "power" "meas_timestamp" "write_timestamp"]);
    
    tablename = "chroma_ps_model2icdas";
    sqlwrite(conn,tablename,data_mes)

    disp('Output data write to server is successful!')
    
    
    end
end

 
%% close database connection
close(conn)