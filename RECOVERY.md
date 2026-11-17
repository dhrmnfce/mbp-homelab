# Homelab recovery guide

Use this checklist when the homelab webpage or SSH connection is unavailable, or when a Healthchecks.io alert arrives. The server is the Ubuntu MacBook Pro; the administration laptop is the MacBook used to connect to it.

## 1. Check the server and address

On the administration laptop, try the webpage at `http://192.168.1.179/` and an SSH connection:

```bash
ssh -i ~/.ssh/homelab_mbp dylan@192.168.1.179
```

If SSH times out, check that the server is powered on, awake, and connected by Ethernet. Its lid being closed has caused a connection timeout before. At the server's own keyboard, run `hostname -I` to see its current address; DHCP can change it. Use the current address in the commands and browser URL below.

If the address is correct but SSH still fails, at the server's own keyboard run:

```bash
systemctl is-active ssh
sudo systemctl status ssh --no-pager
```

If SSH is inactive, start it with `sudo systemctl start ssh`, then retry the SSH connection from the administration laptop.

## 2. Check the web service

Once logged into the server, run:

```bash
systemctl is-active nginx
sudo systemctl status nginx --no-pager
sudo journalctl -u nginx -n 20 --no-pager
```

Read the status and recent messages before changing anything. If Nginx is inactive, check its configuration and start it:

```bash
sudo nginx -t
sudo systemctl start nginx
```

If `nginx -t` reports an error, use its file and line number to investigate before starting the service again.

## 3. If Nginx is active but the custom page is missing

On the server, check whether the page file exists:

```bash
ls -l /var/www/html/index.html
```

If it is missing, check the local restore copy before using it:

```bash
ls -l ~/homelab-backups/index.html
```

If that is the intended page, restore it:

```bash
sudo cp ~/homelab-backups/index.html /var/www/html/index.html
```

This copy is on the same SSD, so it will not help if the SSD fails.

## 4. Verify and record the result

On the server, run `systemctl is-active nginx`. On the administration laptop, reload `http://192.168.1.179/` (or the current server address) and confirm the custom page appears.

Record the date, symptom, relevant status or log message, action taken, and how the result was verified. If the issue remains, keep the command output for further investigation rather than repeatedly restarting services.

## Controlled recovery drill

**Date:** November 16, 2026.

**Scenario:** Intentionally stopped Nginx while SSH remained available.

**Observed:** `systemctl is-active nginx` returned `inactive`. Service status and journal entries showed `Deactivated successfully`, indicating a clean stop. `sudo nginx -t` reported that the configuration syntax was valid.

**Recovery:** Started Nginx with `sudo systemctl start nginx`. A second `systemctl is-active nginx` returned `active`.

**Verification:** Refreshed `http://192.168.1.179/` from the administration MacBook and confirmed the custom page loaded.
