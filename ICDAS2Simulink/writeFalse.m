%% Make connection to database
conn = database('sgdb','postgres','SmartGrid2022','Vendor','POSTGRESQL','Server','NEMO.campus.NIST.GOV','PortNumber',5432);

disp('Connection with database is successful!')

%Set query to execute on the database
%read icdas2model table > pick rows that has false in read_by_model column
%> order rows by data_id in ascending order > pick the first row
query = ['SELECT * ' ...
    'FROM sgdb.public.chroma_ps_icdas2model ' ...
    'WHERE read_by_model = true ' ...
    'ORDER BY data_id ASC '];

%% Execute query and fetch results
data = fetch(conn,query);
simStart=1
simStop=data.data_id(end,:)


%Run simulink model until for loop reaches stop count
 for k = simStart:simStop
     colnames = {'read_by_model'};
newData = {'false'};

%Update the column using where clause
tablename = 'chroma_ps_icdas2model';    
update(conn,tablename,colnames,newData) 
        
 end
 
%% Update table with read receipt and read timestamp
% Define a cell array containing the name of the column that you are updating.
