import telnetlib
import time

# Empyrion server Telnet information
server_ip = "127.0.0.1"  # Replace with your server's IP address
server_port = 30004  # Default Telnet port for Empyrion server
admin_password = "password"  # Replace with your admin password

# Message to send
message = "Hello, players! This is a server announcement."

def send_telnet_command(command):
    try:
        # Connect to the server's Telnet interface
        tn = telnetlib.Telnet(server_ip, server_port, timeout=10)

        # Authenticate as admin
        tn.read_until(b"Please enter admin password:")
        tn.write(admin_password.encode('utf-8') + b"\n")

        # Send the command (message)
        tn.read_until(b">")
        tn.write(command.encode('utf-8') + b"\n")

        # Close the Telnet connection
        tn.close()
        print(f"Message sent: {command}")

    except Exception as e:
        print(f"Error: {str(e)}")

# Main loop to send messages every 10 minutes
while True:
    send_telnet_command(f'say "{message}"')
    time.sleep(600)  # Wait for 10 minutes before sending the next message
