# Repurposed MacBook Pro homelab

Personal infrastructure project — started November 13, 2026.

## Purpose

Practice the installation, remote administration, service operation, troubleshooting, and documentation involved in running a small Linux server on repurposed hardware.

## Hardware and setup

- 17-inch MacBook Pro A1297, with a 2.53 GHz Intel Core i5, 8 GB DDR3 memory, and a 1 TB SATA SSD. 
- Ubuntu Server 24.04.5 LTS installed on the internal SSD.
- Wired Ethernet connection to a home router, with an address assigned by DHCP.
- OpenSSH Server for remote administration from another MacBook Pro.
- Nginx serving a custom page on the home network.

## Work completed

1. Checked the internal drive with macOS Disk Utility First Aid; it reported no errors.
2. Created Ubuntu installation media and installed the standard Ubuntu Server edition.
3. Updated system packages and installed/enabled OpenSSH Server.
4. Connected remotely over SSH from a separate laptop.
5. Installed Nginx and replaced its default page with a custom homelab page.
6. Performed a controlled outage: stopped Nginx, inspected the service status and shutdown messages, restarted Nginx, and verified that the page loaded afterward.
7. Rebooted the server and verified that SSH and Nginx returned to active status and the page remained available.
8. Practiced restoring the custom page from a verified local copy and confirmed it loaded again.
9. Created a health check script and scheduled it with cron to record Nginx status and root filesystem usage every five minutes.

## Health baseline

Captured after installation on November 13, 2026:

| Check | Observed result |
| --- | --- |
| Memory | 7.7 GiB total; 7.2 GiB available |
| Swap | 4.0 GiB total; 0 used |
| Root filesystem | 915 GiB total; 6.8 GiB used; 862 GiB available; 1% used |
| Failed systemd units | 0 |

These are point-in-time observations, not uptime or performance guarantees.

## Useful commands

```bash
hostname -I
systemctl is-active ssh nginx
systemctl status nginx --no-pager
journalctl -u nginx -n 20 --no-pager
free -h
df -h /
systemctl --failed --no-pager
```

## Controlled outage record

**Scenario:** Nginx was intentionally stopped to practice service recovery.

**Observed impact:** `systemctl status nginx` showed `inactive (dead)`. The status messages reported a clean stop (`Deactivated successfully` and `status=0/SUCCESS`), rather than a crash. Browser behavior during the stopped period was not recorded.

**Recovery and verification:** Started Nginx, confirmed its status was `active`, and refreshed the page successfully. Rebooted the server afterward and confirmed that SSH, Nginx, and the page were available again.

## Page restore drill

**Date:** November 14, 2026.

**Preparation:** Copied `/var/www/html/index.html` to `~/homelab-backups/index.html` and used `cmp` to confirm the files matched.

**Simulation:** Moved the live page to `index.html.offline`, then restored `index.html` from the copy in the home directory.

**Verification:** `cmp` confirmed the restored file matched the backup, and the custom page loaded in the browser again.

This was a restore exercise using a second copy on the same SSD. It does not protect against failure of that SSD.

## Scheduled health check

`healthcheck.sh` prints the check time, whether Nginx is active, and root filesystem usage. The script correctly reported `inactive` during a controlled Nginx stop and `active` after the service was restarted.

The server runs it every five minutes through the user's crontab:

```cron
*/5 * * * * /home/dylan/homelab/healthcheck.sh >> /home/dylan/homelab/health.log 2>&1
```

`crontab -l` shows the schedule, and `tail -n 8 ~/homelab/health.log` shows recent output. This records checks in a local log; it does not send an alert if Nginx stops.

## Next steps

- Record a simple network diagram and a short setup/recovery runbook.
- Configure SSH key authentication, then test it before changing password-login settings.
- Add an alert for failed health checks and a log retention policy.
- Make a backup on a separate device and test restoring from it.
