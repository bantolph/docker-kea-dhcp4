#!/bin/bash

# Start the first process
/usr/sbin/kea-ctrl-agent -c /etc/kea/kea-ctrl-agent.conf &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start kea-ctrl-agent: $status"
  exit $status
fi

# Start the second process
/usr/sbin/kea-dhcp4 -c /etc/kea/kea-dhcp4.conf &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start kea-dhcp4: $status"
  exit $status
fi

# Naive check runs checks once a minute to see if either of the processes exited.
# This illustrates part of the heavy lifting you need to do if you want to run
# more than one service in a container. The container exits with an error
# if it detects that either of the processes has exited.
# Otherwise it loops forever, waking up every 60 seconds

while sleep 60; do
  ps aux |grep kea-ctrl-agent |grep -q -v grep
  PROCESS_1_STATUS=$?
  ps aux |grep kea-dhcp4 |grep -q -v grep
  PROCESS_2_STATUS=$?
  # If the greps above find anything, they exit with 0 status
  # If they are not both 0, then something is wrong
  if [ $PROCESS_1_STATUS -ne 0 -o $PROCESS_2_STATUS -ne 0 ]; then
    echo "One of the processes has already exited."
    exit 1
  fi
done
