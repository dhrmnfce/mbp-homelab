# Homelab network diagram

```text
Main MacBook Pro (administration laptop)
  - SSH client: remote terminal access
  - Web browser: views the homelab page
               |
               | Home network (SSH and HTTP)
               v
Home router / local network
  - Assigns the server an address through DHCP
               |
               | Ethernet cable
               v
Old MacBook Pro (Ubuntu Server, hostname: homelab-mbp)
  - ssh.service: accepts remote logins
  - nginx.service: serves /var/www/html/index.html
  - cron: runs ~/homelab/healthcheck.sh every five minutes
          and appends output to ~/homelab/health.log
```

The server address used during setup and testing was `192.168.1.179`. It is assigned by DHCP, so it can change. Run `hostname -I` on the server to check its current address.

An SSH request from the main MacBook reaches the server's SSH service. A browser request to `http://192.168.1.179/` reaches Nginx, which returns the custom page. These connections have been tested on the home network. This diagram does not show a publicly accessible website or remote access from outside the home.

For monitoring, the server also sends an **outbound** HTTPS check-in to Healthchecks.io after each scheduled health check. Healthchecks.io can send an email when it receives a failure signal or expected check-ins stop arriving. The server does not accept incoming connections from Healthchecks.io.
