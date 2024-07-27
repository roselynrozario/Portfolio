# Real Time Intelligent Systems
# Final Project - Server
# Roselyn R., Aashai A., Alberto B., Jaelynn K.

# Packages
import socket
import time
import pandas as pd

# Stream Data into Server
aapl_df = pd.read_csv("AAPL_2024.csv")
aapl_2024_list = list(aapl_df['close'])

def start_server(host, port):
    
    # Create Socket Object
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    
    # Bind to the Server Address
    server_socket.bind((host, port))
    
    # Listen for Incoming Connections
    server_socket.listen()
    print(f"Server is listening on {host}:{port}")
    
    # Accept A Connection
    client_socket, addr = server_socket.accept()
    print(f"Connected by {addr}")
    
    # Send Data Items One by One
    for item in aapl_2024_list:
        client_socket.sendall(str(item).encode())
        time.sleep(0.5)
        response = client_socket.recv(1024).decode()  # Wait for Client Acknowledgment
        if response != "ACK":
            break
    
    # Close Connection
    client_socket.close()
    server_socket.close()

# Start Server
start_server('127.0.0.1', 65432)