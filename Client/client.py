import socket
import os
import time
HOST = "192.168.1.78"  # The server's hostname or IP address
PORT = 8080        # The port used by the server


def elegir(arr):
    decision="hold"
    menos=0
    mas=0
    for i in arr:
        if i==21:
            mas=10000
        elif i >16 and i<22:
            mas+=1
        elif i >21:
            continue
        else:
            menos+=1
    if mas<menos:
        decision="call"
    return decision

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.connect((HOST, PORT))
    arr=[0]
    cartas=[]
    pregunta=False
    jugador=""
    while(True):
        mensaje2=""
        response_data = s.recv(1024).decode("utf-8") 
        if "kill" in response_data:
            break
        elif "?" in response_data:
            pregunta=True
        elif len(response_data)<4:
            cartas.append(response_data[:-1])
            if response_data[0] in ['J','K','Q']:
                for i in range(len(arr)):
                    arr[i]+=10
            elif response_data[0] == 'A':
                arrA=[]
                for i in range(len(arr)):
                    arrA.append(arr[i]+1)
                    arr[i]+=11
                arr=arr+arrA
            else:
                for i in range(len(arr)):
                    st=response_data[:-1]
                    arr[i]+=int(st)
        else:
            if("Eres el Jugador" in response_data):
               jugador=response_data
            else:
                mensaje2=response_data
        if os.name=='nt':
            os.system('cls')    
        else:
            os.system('clear')
        print(jugador)
        print(mensaje2)
        print(cartas)
        print(arr)
        if(pregunta):
            print("¿Quieres hold o call?")
            mensaje = elegir(arr)
            print(mensaje)
            time.sleep(0.5)
            s.sendall(bytes(mensaje, 'utf-8'))
            pregunta=False
    s.close()