$TTL 604800
@       IN      SOA     dhruv.com.  root.dhruv.com(
                        2024121701; serial
                        604800; refresh
                        86400; retry
                        2419200; expire
                        604800); negative cache

; Name servers
@       IN      NS      local_slave.

; A Records
webserver   IN      A      192.168.1.2  