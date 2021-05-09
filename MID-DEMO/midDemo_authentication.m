func_get_authdata();

userNum = 6;
knnNum = 5;

user = func_authentication_module(userNum,12,knnNum);
% fprintf("THIS IS USER %d\n", user);

CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
contents = strcat("  \fontsize{30}This is User ",int2str(user));
f = msgbox(contents, 'Answer',CreateStruct);