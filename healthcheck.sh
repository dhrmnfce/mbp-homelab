#!/bin/bash
echo "Checked: $(date)"
status=0
nginx_state=$(systemctl is-active nginx || true)
echo "Nginx: $nginx_state"
if [ "$nginx_state" != active ]; then
  status=1
fi

if curl --fail --silent --show-error --max-time 5 --output /dev/null http://127.0.0.1/; then
  echo "HTTP: reachable"
else
  echo "HTTP: failed"
  status=1
fi

df -h /

# Read the private ping URL from the server, then report this check's result.
hc_file=/home/dylan/.config/homelab/healthchecks-url
if [ -r "$hc_file" ]; then
  hc_url=$(cat "$hc_file")
  if [ -n "$hc_url" ]; then
    if curl --fail --silent --show-error --max-time 10 --output /dev/null "${hc_url%/}/$status"; then
      echo "Healthchecks: reported exit code $status"
    else
      echo "Healthchecks: report failed"
    fi
  else
    echo "Healthchecks: URL file is empty"
  fi
else
  echo "Healthchecks: URL file is missing or unreadable"
fi

exit "$status"
