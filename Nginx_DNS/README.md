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
1. **DNS Master Server**
Purpose: Primary DNS server managing zone files.
Base Image: internetsystemsconsortium/bind9:9.18
Key Files:
named.conf: Configures zones and allows transfers to the slave.
db.example.local: Contains A records and SOA configuration for example.local.
Static IP: 192.168.1.2
2. **DNS Slave Server**
Purpose: Backup DNS server to replicate master zones.
Base Image: internetsystemsconsortium/bind9:9.18
Key Files:
named.conf: Configures zone as a slave and synchronizes from the master.
Static IP: 192.168.1.3
3. **Web Server**
Purpose: Serves static content and validates DNS resolution.
Base Image: nginx:latest
Configuration:
Static IP: 192.168.1.1
Mounted static folder with index.html.
4. **Custom Network**
Purpose: Ensures consistent IP allocation and inter-container communication.
Subnet: 192.168.1.0/24
How to Run
- **Step 1: Create the Custom Network**
bash
Copy code
docker network create --subnet=192.168.1.0/24 custom-network
- **Step 2: Bring Up Containers**
bash
Copy code
docker-compose up -d
- **Step 3: Verify Setup**
Check running containers:
bash
Copy code
docker ps
Inspect the network:
bash
Copy code
docker network inspect custom-network
- **Step 4: Test DNS Resolution**
Use a tool like dig or nslookup:

```bash
Copy code
dig @192.168.1.2 www.example.local
Configuration Details
DNS Master Zone File
File: db.example.local

text
Copy code
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
File: nginx.conf

nginx
Copy code
server {
    listen 80;
    server_name localhost;

    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
}
# Testing
-   **1. Access the Web Server**
Open a browser and navigate to:

arduino
Copy code
http://www.example.local
-   **2. DNS Redundancy**
Shut down the master DNS container and verify that the slave DNS resolves www.example.local.
Notes
Static IPs are crucial for DNS records; they are defined in docker-compose.yml.
Ensure the master DNS server synchronizes with the slave before testing redundancy.
Use tools like Wireshark to debug DNS queries if needed.