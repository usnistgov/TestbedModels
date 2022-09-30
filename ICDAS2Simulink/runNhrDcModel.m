% This script runs the NHR DC emulator model in conjunction with ICDAS
% by Allen Goldstein, NIST
% 8/11/2022
% Runs on MATLAB 2020b
%
% ICDAS NHRDCPowerModel init and run script must run before this code is started

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
    'FROM sgdb.public.nhr_dc_icdas2model ' ...
    'ORDER BY data_id ASC ' ...
    'LIMIT 1'];

data_db2sim_check = fetch(conn,query);

%% Run simulation

%waitbar
hWaitbar = waitbar(0, 'NHR DC Simulation', 'Name', 'ICDAS<>SIMULINK','CreateCancelBtn','delete(gcbf)');

% load the model and set the mask values
sys=load_system('NHR9200Model4960_2020b');
IPHandle = getSimulinkBlockHandle('NHR9200Model4960_2020b/NHR 9200 (4960) Input Panel');
SSHandle = getSimulinkBlockHandle('NHR9200Model4960_2020b/NHR 9200 Safety Settings');
SlewHandle = getSimulinkBlockHandle('NHR9200Model4960_2020b/NHR 9200');
while 1
    % The loop begins by reading through all the records in nhr_dc_icdas2model until a record with rear_by_model == false is found
    
    % first check if the database exists and has any data in it.
    if isempty(data_db2sim_check.data_id) == 1
        disp('There are no settings available in the database. Aborting simulation...');
        break;
    else
        
        % gets a record from the DB.
        disp('Transferring settings from database to Matlab...');
        query = ['SELECT * ' ...
            'FROM sgdb.public.nhr_dc_icdas2model ' ...
            'WHERE read_by_model = false ' ...
            'ORDER BY data_id ASC ' ...
            'LIMIT 1'];
        
        data = fetch(conn,query);
        disp('Reading from icdas2model is successful!')
        
        dID = data.data_id;     % If the last record's read_by_model == true,dID will be empty
    
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
        
        %Skip over this if the last record read had read_by_model == false.
        if isempty(dID) == 1
            % run last settings if no new settings from ICDAS
            disp('last test settings is reached!')
            query = ['SELECT * ' ...
                'FROM sgdb.public.nhr_dc_icdas2model ' ...
                'WHERE read_by_model = true ' ...
                'ORDER BY data_id DESC ' ...
                'LIMIT 1'];
            data_last = fetch(conn,query);
            
%             op_state = data_last.operating_state;
%             Vmch = data_last.voltage; Vmdch = Vmch;
%             Imch = data_last.current; Imdch = Imch;
%             Pmch = data_last.power; Pmdch = Pmch;
%             Rsch = data_last.resistance; Rsdch = Rsch;
%             Vmin = 0; Tvmin = 2;
%             Vmax = data_last.max_voltage; Tvmax = data_last.max_voltage_time;
%             Imaxch = data_last.max_current; Timaxch = data_last.max_current_time;
%             Imaxdch = Imaxch; Timaxdch = Timaxch;
%             Pmaxch = data_last.max_power; Tpmaxch = data_last.max_power_time;
%             Pmaxdch = Pmaxch; Pmaxdch = Pmaxch;
%             Vslew = data_last.voltage_slew_rate;
%             Islew = data_last.current_slew_rate;
%             Rslew = data_last.resistance_slew_rate;
%             Pslew = data_last.power_slew_rate;
%             Vbset = data_last.battery_detect_voltage;

            % set the input parameters (Note, this might also be possible to do using tables)
            % Input Panel
            set_param(IPHandle,'op_state',num2str(data_last.operating_state));
            set_param(IPHandle,'Vmch',num2str(data_last.voltage));
            set_param(IPHandle,'Vmdch',num2str(data_last.voltage));
            set_param(IPHandle,'Imch',num2str(data_last.current));
            set_param(IPHandle,'Imdch',num2str(data_last.current));
            set_param(IPHandle,'Pmch',num2str(data_last.power/1000));
            set_param(IPHandle,'Pmdch',num2str(data_last.power/1000));
            set_param(IPHandle,'Rsch',num2str(data_last.resistance));
            
            % Safety Settings
            set_param(SSHandle,'Vmin',num2str(10));
            set_param(SSHandle,'Tvmin',num2str(2));
            set_param(SSHandle,'Vmax',num2str(data_last.max_voltage));
            set_param(SSHandle,'Tvmax',num2str(data_last.max_voltage_time));
            set_param(SSHandle,'Imaxch',num2str(data_last.max_current)); 
            set_param(SSHandle,'Timaxch',num2str(data_last.max_current_time));
            set_param(SSHandle,'Imaxdch',num2str(data_last.max_current)); 
            set_param(SSHandle,'Timaxdch',num2str(data_last.max_current_time));
            set_param(SSHandle,'Pmaxch',num2str(data_last.max_power/1000));
            set_param(SSHandle,'Tpmaxch',num2str(data_last.max_power_time));
            set_param(SSHandle,'Pmaxdch',num2str(data_last.max_power/1000));
            set_param(SSHandle,'Tpmaxdch',num2str(data_last.max_power_time));
            
            % Slew Rate Settings
            set_param(SlewHandle,'Vslew',num2str(data_last.voltage_slew_rate));
            set_param(SlewHandle,'Islew',num2str(data_last.current_slew_rate));
            set_param(SlewHandle,'Rslew',num2str(data_last.resistance_slew_rate));
            set_param(SlewHandle,'Pslew',num2str(data_last.power_slew_rate));
            set_param(SlewHandle,'Vbset',num2str(data_last.battery_detect_voltage));
            
            while 1
                % wait in this loop until there is a new record written the Labview module
                sim('NHR9200Model4960_2020b')
                
                % Think about keeping the sim running until LV shutdown or cancel
                %set_param(sys,'SimulationCommand','start')    
                
                time = datetime('now','Format','yyyy-MM-dd HH:mm:ss.S' );
                data_meas = table(Vout.data(end,:),Iout.data(end,:),Pout.data(end,:),time,time,...
                                'VariableNames',["voltage" "current" "power" "meas_timestamp" "write_timestamp"]);
                tablename = 'nhr_dc_model2icdas';
                sqlwrite(conn,tablename,data_meas);
                
                 query = ['SELECT * ' ...
                    'FROM sgdb.public.nhr_dc_icdas2model ' ...
                    'WHERE read_by_model = false ' ...
                    'ORDER BY data_id ASC ' ...
                    'LIMIT 1'];

                data = fetch(conn,query);
    
                dID = data.data_id;   
                
                % draw the progress bar
                if ~ishandle(hWaitbar)
                    % Stop the if cancel button was pressed
                    disp('Stopped by user');
                    break;
                else
                    % Update the wait bar
                i=data_last.data_id;
                waitbar((Pout.data(end,:)/data_last.max_power),hWaitbar, ['Power percent of max for data id (last settings):  ' num2str(i)]);
                end
                
                
                if isempty(dID) == 0
                    break
                end
                
            end
                
                
            
        end  % if isempty(dID) == 1
        
        % Update the record with read_by_model = true and the time of the last read
        colnames = {'read_by_model','read_timestamp'};
        
        readTime = datetime('now','Format','yyyy-MM-dd HH:mm:ss.S' );
        newData = {'true',datestr(readTime,31)};
        
        tablename = 'nhr_dc_icdas2model';
        whereclause = ['WHERE data_id ='  num2str(data.data_id)];
        
        update(conn,tablename,colnames,newData,whereclause)
        
        disp('icdas2model update with read receipt and read timestamp is successful!')
        
        
    end
end