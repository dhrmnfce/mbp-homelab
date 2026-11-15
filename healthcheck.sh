#!/bin/bash
echo "Checked: $(date)"
echo "Nginx: $(systemctl is-active nginx)"
df -h /
