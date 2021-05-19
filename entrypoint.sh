#!/bin/bash

# the config file to use for the control agent
CONFIG_FILE="/etc/kea-ctrl-agent/kea-ctrl-agent.conf"

# if the following environment variables are not set, then use some defaults
if [ -z ${CONTROL_AGENT_HOST+x} ]; then 
    CONTROL_AGENT_HOST="127.0.0.1"
fi

if [ -z ${CONTROL_AGENT_PORT+x} ]; then 
    CONTROL_AGENT_PORT="8000"
fi
echo "CONTROL AGENT HOST: $CONTROL_AGENT_HOST"
echo "CONTROL AGENT PORT: $CONTROL_AGENT_PORT"

# Create config file for control agent from template
sed s/%%%CONTROL_AGENT_HOST%%%/$CONTROL_AGENT_HOST/g $CONFIG_FILE.tmpl | sed s/%%%CONTROL_AGENT_PORT%%%/$CONTROL_AGENT_PORT/g > $CONFIG_FILE

# Start the Control Agent
/usr/sbin/kea-ctrl-agent -c $CONFIG_FILE &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start kea-ctrl-agent: $status"
  exit $status
fi

# Start the DHCPv4 Server
/usr/sbin/kea-dhcp4 -c /etc/kea-dhcp4/kea-dhcp4.conf 
