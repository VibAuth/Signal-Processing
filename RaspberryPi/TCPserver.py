# Echo server program
import socket
from os.path import exists
import os
import sys

def run_server(directory,fileName,fileNum):
    HOST = ''                 # Symbolic name meaning all available interfaces
    PORT = 50007              # Arbitrary non-privileged port
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind((HOST, PORT))
    s.listen(1)
    
    conn, addr = s.accept()
    print('Connected by ', addr)
    conn.sendall(filenum.encode())

    print("file location: ", directory+"/"+filename)
    if not exists(directory+"/"+filename):
        print("file not exists")
        msg = "error"
        conn.sendall(msg.encode())
        conn.close()
        return
    
    fileSize = str(getFileSize(filename, directory))
    print("fileSize:", fileSize)
    conn.sendall(fileSize.encode())
    print("sent filesize")

    receiverReady = conn.recv(1024)
    if receiverReady.decode()=="ready":
        print("receiver ready")
        # conn.sendall(getFileData(filename,directory).encode())
        with open(filename, 'rb') as f:
            try:
                data = f.read(1024)
                while data:
                    conn.send(data)
                    data = f.read(1024)
                print("sent ", fileName)
            except Exception as ex:
                print(ex)

    conn.close()

def getFileSize(filename, directory):
    fileSize = os.path.getsize(directory+"/"+filename)
    return str(fileSize)

def getFileData(filename, directory):
    with open(directory+"/"+filename, 'r', encoding="UTF-8") as f:
        data = ""
        for line in f:
            data+=line
    return data

if __name__ == '__main__':
    if len(sys.argv)<3:
        print("set filename, filenumber")
    filename = sys.argv[1]
    filenum = sys.argv[2]
    run_server(directory=str(os.getcwd()), fileName=filename, fileNum=filenum)
