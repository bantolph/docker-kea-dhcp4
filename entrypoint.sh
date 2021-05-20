#!/bin/bash

# the config file to use for the control agent
CONFIG_FILE="/etc/kea-ctrl-agent/kea-ctrl-agent.conf"

# See if the DEBUG level was set and that it is an integer
if [ -z ${DEBUG+x} ]; then 
    echo "Debug not set, daemons will be started with debugging disabled"
    DEBUG_LEVEL=10
elif [ ! -z "${DEBUG##*[!0-9]*}" ]; then
    DEBUG_LEVEL="$DEBUG"
    DEBUGGING=YES
    echo "Daemons will be started with debugging at level $DEBUG_LEVEL"
    # set a bs value so the config doesnt bomb out
else
    echo "Debug is not an integer value, daemons will be started with debugging disabled"
    DEBUG_LEVEL=10
fi

# if the following environment variables are not set, then use some defaults
if [ -z ${CONTROL_AGENT_HOST+x} ]; then 
    CONTROL_AGENT_HOST="127.0.0.1"
fi

if [ -z ${CONTROL_AGENT_PORT+x} ]; then 
    CONTROL_AGENT_PORT="8000"
fi
echo "CONTROL_AGENT_HOST: $CONTROL_AGENT_HOST"
echo "CONTROL_AGENT_PORT: $CONTROL_AGENT_PORT"

# Create config file for control agent from template
sed s/%%%CONTROL_AGENT_HOST%%%/$CONTROL_AGENT_HOST/g $CONFIG_FILE.tmpl | sed s/%%%CONTROL_AGENT_PORT%%%/$CONTROL_AGENT_PORT/g > $CONFIG_FILE

# set the debug level in the control agent config
sed -i s/%%%DEBUG_LEVEL%%%/$DEBUG_LEVEL/g $CONFIG_FILE

# Start the Control Agent with debug flag on or off depending on level
if [ -z ${DEBUGGING+x} ]; then 
    /usr/sbin/kea-ctrl-agent -c $CONFIG_FILE &
else
    /usr/sbin/kea-ctrl-agent -d -c $CONFIG_FILE &
fi
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start kea-ctrl-agent: $status"
  exit $status
fi

# set debug level in dhcp daemon config file
sed -i s/%%%DEBUG_LEVEL%%%/$DEBUG_LEVEL/g /etc/kea-dhcp4/kea-dhcp4.conf

# Start the DHCPv4 Server 
if [ -z ${DEBUGGING+x} ]; then 
    /usr/sbin/kea-dhcp4 -c /etc/kea-dhcp4/kea-dhcp4.conf 
else
    /usr/sbin/kea-dhcp4 -d -c /etc/kea-dhcp4/kea-dhcp4.conf 
fi
