% % python3 mputocsv.py; python3 TCPserver.py accel_data_time.csv auth; python3 enter_terminate.py

% % Get Auth data
close all;
clearvars;
func_get_authdata_final();

userNum = 15;
knnNum = 3;

% % Classification
user = func_authentication_final(userNum, 12, knnNum);
fprintf("\nTHIS IS USER %d\n", user);

%% Send result
ip = '192.168.137.';
port = 4000;
func_send_result_to_watch(ip, port, user);

% CreateStruct.Interpreter = 'tex';
% CreateStruct.WindowStyle = 'modal';
% contents = strcat("  \fontsize{30}This is User ",int2str(user));
% f = msgbox(contents, 'Answer',CreateStruct);