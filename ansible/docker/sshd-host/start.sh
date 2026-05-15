#!/bin/bash
set -e

# Start SSHD in background
/usr/sbin/sshd &

# Start Alloy in foreground
exec /usr/local/bin/run-alloy.sh
