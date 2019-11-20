
import socket

HOST = "172.32.141.179"  # The server's hostname or IP address
PORT = 8080        # The port used by the server

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    while(True):
        response_data = s.recv(1024).decode("utf-8") 
        if "kill" in response_data:
            break

        print (response_data)
        if "?" in response_data:
            mensaje = input()
            s.sendall(bytes(mensaje, 'utf-8'))

 
        

    s.close()
