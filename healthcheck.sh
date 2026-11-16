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
exit "$status"
