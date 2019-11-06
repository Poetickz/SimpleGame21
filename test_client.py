
import socket


HOST = 'localhost'  # The server's hostname or IP address
PORT = 8080        # The port used by the server

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    while(True):
        response_data = s.recv(1024).decode("utf-8") 
        print (response_data)

    s.close()