#!/bin/bash

# Define the ports used by Miner
MINING_PORTS=(3333 5555 7777 9000 8080 80 443)

# Check if iptables is installed
if ! command -v iptables &> /dev/null; then
    echo "iptables command not found. Please make sure iptables is installed."
    exit 1
fi

# Flush existing iptables rules related to Miner
sudo iptables -F
sudo iptables -X

# Block incoming and outgoing connections to the Miner ports
for port in "${MINING_PORTS[@]}"; do
    sudo iptables -A INPUT -p tcp --dport "$port" -j DROP
    sudo iptables -A OUTPUT -p tcp --dport "$port" -j DROP
    echo "Miner mining activity blocked on port $port"
done

# Find and kill processes using the specified ports
for port in "${MINING_PORTS[@]}"; do
    pid=$(sudo lsof -t -i tcp:"$port")
    if [ -n "$pid" ]; then
        echo "Found process using port $port. Terminating process $pid"
        sudo kill "$pid"
    fi
done
