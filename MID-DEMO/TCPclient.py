import socket
import pandas as pd

def main():
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.connect(('192.168.137.192', 50007))
        fileNum = s.recv(100)
        fileNum = fileNum.decode()
        
        reSize = s.recv(1024)
        reSize = reSize.decode()
        
        ## 디렉토리에서 파일을 못찾아 error를 보냈을 경우
        if reSize == "error":
                return 0
        
        ## client가 파일 크기를 받았고, 파일 내용을 받을 준비가 되었다는 것을 알림
        msg = "ready"
        s.sendall(msg.encode())
        fileSize = reSize
        
        data = s.recv(1024)
        received_data = 0
        filename = 'new_file_'+fileNum+'.csv'
        with open(filename, 'w', encoding="UTF-8") as f:
            ## 파일 사이즈만큼 recv
            try:
                while data:
                    f.write(data.decode())
                    received_data += len(data)
                    data = s.recv(1024)
            except Exception as ex:
                print(ex)
        
        return [fileSize, received_data, filename]