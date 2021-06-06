%% Get Auth data
func_get_authdata_final();

userNum = 15;
knnNum = 3;

%% Classification
user = func_authentication_final(userNum, 12, knnNum);
fprintf("THIS IS USER %d\n", user);

%% Send result
% ip = '';
% port = 4000;
% func_send_result_to_watch(ip, port, user);

% CreateStruct.Interpreter = 'tex';
% CreateStruct.WindowStyle = 'modal';
% contents = strcat("  \fontsize{30}This is User ",int2str(user));
% f = msgbox(contents, 'Answer',CreateStruct);