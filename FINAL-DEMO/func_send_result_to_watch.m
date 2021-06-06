function func_send_result_to_watch (ip, port, user)
% jinseon : '192.168.0.221'
% heesu : '192.168.0.215'
% port : 4000
t = tcpip(ip, port);
fopen(t);

% write a message
fwrite(t, user);

% close the connection
fclose(t);