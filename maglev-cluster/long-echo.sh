#!/bin/bash

#
# Long Echo Server
# Accepts TCP connections on $PORT (default: 9000).
# Echo's back any received data.
# Times out after $NC_MAX_IDLE seconds of inactivity (default: 10).
#
# Environment variables:
#   PORT            - TCP port to listen on (default: 9000)
#   NC_MAX_IDLE    - Netcat max idle time before timeout (default: 10)
#   KEEP_ALIVE     - If set, a background routine will log "ping" messages every 2 seconds.
#   DEBUG          - If set, debug messages will be printed.
#   HOSTNAME       - If set, used in log messages; otherwise, system hostname or "long-echo".
#


if [ -z "$HOSTNAME" ]; then
	if [ -z $(command -v hostname) ]; then
		HOSTNAME="long-echo"
	else
		HOSTNAME=$(hostname)
	fi
fi

if [ -z $(command -v nc) ]; then
	echo "[$HOSTNAME] nc (netcat) command not found. Please install netcat to use this script."
	exit 1
fi

if [ -z  "$NC_MAX_IDLE" ]; then
	NC_MAX_IDLE=10
fi

if [ -z "$PORT" ]; then
	PORT=9000
fi


while true; do
	if [ -n "$DEBUG" ]; then echo "[$HOSTNAME][$SECONDS] Cleanup stale in/out"; fi
	rm -f out
	if [ -n "$DEBUG" ]; then echo "[$HOSTNAME][$SECONDS] Init FIFO"; fi
	mkfifo out

	# Background routine logs passage of time.
	if [ -n "$KEEP_ALIVE" ]; then
		echo "[$HOSTNAME][$SECONDS] Starting background time-logger";
		( while true; do echo "[$HOSTNAME][$SECONDS] Ping!" >> out; sleep 2; done) &
		BG_PID=$!
		if [ -n "$DEBUG" ]; then echo "[$HOSTNAME][$SECONDS] BG_PID is $BG_PID"; fi
	fi


	# Start netcat listener.
	sed -u "s/\(^.*$\)/[$HOSTNAME] Server says: '\1'/g" out | nc -w $NC_MAX_IDLE -nvvlp $PORT 2>&1 1> out | sed -u "s/\(^.*$\)/[$HOSTNAME] '\1'/g"

	echo;
	echo "[$HOSTNAME][$SECONDS] Listener: connection-closed or wait-timeout";
	echo "[$HOSTNAME][$SECONDS] Restarting listener..."
	if [ -n "$DEBUG" ]; then
		if [ -n "$KEEP_ALIVE" ]; then
			echo "[$HOSTNAME][$SECONDS] Cleanup routines: '$BG_PID'";
			kill $BG_PID
		else
			echo "[$HOSTNAME][$SECONDS] No background routine to kill";
		fi
	fi

done
