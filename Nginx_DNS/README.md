# Docker DNS and Web Server Setup

## Project Overview

This project sets up a containerized environment with the following components:

- **DNS Servers**: A master and a slave DNS server using BIND9.
- **Web Server**: An NGINX server serving a static web page.
- **Custom Docker Network**: Ensures static IP assignment for easy DNS management.

This configuration allows a web server to be accessible via a domain name resolved by the DNS servers. The DNS records are managed within the master server and synced with the slave.

---

## Architecture

Below is the architecture of the setup:

1. **DNS Master Server**:
   - Handles the primary DNS zone configuration.
   - Responsible for zone file updates.

2. **DNS Slave Server**:
   - Synchronizes zone data from the master.
   - Provides redundancy.

3. **Web Server (NGINX)**:
   - Hosts and serves static content.
   - Configured with a static IP (`192.168.1.1`).

4. **Custom Network**:
   - Enables static IP assignment.
   - Facilitates communication between services.

---

### Architecture Diagram
*(Diagram Description: A custom Docker network connecting the DNS master, DNS slave, and NGINX web server with assigned static IPs.)*

> Unfortunately, I cannot generate or include diagrams directly in a text-only README. However, you can use tools like [draw.io](https://draw.io) or [Excalidraw](https://excalidraw.com) to create a network diagram.

---

## Folder Structure

```bash
project-directory/
├── docker-compose.yml          # Compose file for container orchestration
├── dns1-config/                # Configuration files for DNS Master
│   ├── named.conf              # Main configuration for BIND9
│   └── db.example.local        # Zone file for 'example.local'
├── dns2-config/                # Configuration files for DNS Slave
│   ├── named.conf              # Main configuration for BIND9 Slave
├── nginx.conf                  # NGINX configuration file
└── static/                     # Static content served by NGINX
    └── index.html              # Sample HTML file
```
---
## Services Explained
Services Explained
1. **DNS Master Server**
Purpose: Primary DNS server responsible for managing zone files and resolving domain names.
Base Image: internetsystemsconsortium/bind9:9.18
Key Files:
named.conf: The main configuration file for BIND9, defining zones and settings.
db.example.local: The zone file that contains A records and SOA (Start of Authority) records for the example.local domain.
IP Address: Static IP 192.168.1.2
The DNS master is configured to handle DNS queries for the example.local domain and synchronize with the slave DNS server.
Why we use it: This server is responsible for managing the authoritative DNS records for the domain and updating the slave DNS server.
2. **DNS Slave Server**
Purpose: Backup DNS server that synchronizes zone files from the master DNS server to provide redundancy.
Base Image: internetsystemsconsortium/bind9:9.18
Key Files:
named.conf: The configuration for the DNS slave, which points to the master server for zone transfers.
IP Address: Static IP 192.168.1.3
The DNS slave server acts as a backup to the master and provides DNS services if the master becomes unavailable.
Why we use it: Redundancy in DNS servers ensures continuous resolution of domain names, even if the master server goes down.
3. **Web Server (NGINX)**
Purpose: A simple NGINX web server that serves static content to validate the DNS resolution.
Base Image: nginx:latest
Configuration:
Serves the static content in the /static folder, with an index.html file as the home page.
Static IP 192.168.1.1
This web server is the target of DNS resolution, so the DNS records for www.example.local point to this server.
Why we use it: The web server serves as the final destination of the DNS resolution, hosting a simple static webpage to verify that DNS is working.
4. **Custom Network**
Purpose: A Docker network that ensures containers can communicate with each other by using static IP addresses.
Subnet: 192.168.1.0/24
The custom network ensures that the DNS servers (both master and slave) and the web server all reside in the same network and can resolve the domain names correctly.
Why we use it: A custom network simplifies inter-container communication and ensures consistent IP addresses, which are required for DNS resolution.
---
## How to Run
- **Step 1: Create the Custom Network**
```bash
docker network create --subnet=192.168.1.0/24 custom-network 
```
- **Step 2: Bring Up Containers**
```bash
docker-compose up -d
```
- **Step 3: Verify Setup**
### Check running containers:
``` bash
docker ps
```
### Inspect the network:
```bash
docker network inspect custom-network
```
- **Step 4: Test DNS Resolution**
### Use a tool like dig or nslookup:
```bash
dig @192.168.1.2 www.example.local
```

## Configuration Details
- **DNS Master Zone File**
- File: db.example.local
```bash
$TTL 86400
@   IN  SOA     dns1.example.local. admin.example.local. (
                    2024121801 ; Serial
                    3600       ; Refresh
                    1800       ; Retry
                    1209600    ; Expire
                    86400 )    ; Minimum TTL

    IN  NS      dns1.example.local.
    IN  NS      dns2.example.local.

dns1    IN  A   192.168.1.2
dns2    IN  A   192.168.1.3
www     IN  A   192.168.1.1
```
---
# NGINX Configuration
- **File: nginx.conf**
- **nginx**
``` bash
    server {
        listen 80;
        server_name localhost;

        location / {
            root /usr/share/nginx/html;
            index index.html;
        }
    }
```