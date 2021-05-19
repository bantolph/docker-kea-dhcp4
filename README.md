Dockerfile for ISC Kea DHCP4 Daemon.

This runs the Kea DHCP4 Daemon and opens up the a REST API Interface for control.  This server is meant to be used in combination with DHCP relays and is not intended to be used to hand out leases on an interface that it listens to.

This has been setup to be as ephemeral as possible and easy to integrate into Kubernetes.

It takes the following enviornment variables for the REST interface:
```
CONTROL_AGENT_PORT
CONTROL_AGENT_HOST
```

CONTORL_AGENT_PORT defaults to 8000, and the CONTROL_AGENT_HOST is 0.0.0.0 so it will listen on any interface/address.

The DHCP4 daemon reads in `/etc/kea-dhcp4/kea-dhcp4.conf` as it's starting configuraiton file which includes other files for DDNS (Dynamic DNS) updates, general DHCP options, and subenetting information :

```
// Config file for Docker 
{
"Dhcp4": {
    // Add names of your network interfaces to listen on.
    "interfaces-config": {
        "dhcp-socket-type": "udp"
    },
    <?include "/etc/kea-ddns/kea-dhcp4.ddns"?>
    "control-socket": {
        "socket-type": "unix",
        "socket-name": "/tmp/kea-dhcp4-ctrl.sock"
    },
    "lease-database": {
        "type": "memfile",
        "lfc-interval": 3600
    },
    "expired-leases-processing": {
        "reclaim-timer-wait-time": 10,
        "flush-reclaimed-timer-wait-time": 25,
        "hold-reclaimed-time": 3600,
        "max-reclaim-leases": 100,
        "max-reclaim-time": 250,
        "unwarned-reclaim-cycles": 5
    },

    "renew-timer": 900,
    "rebind-timer": 1800,
    "valid-lifetime": 3600,
    <?include "/etc/kea-option-data/kea-dhcp4.options"?>
    <?include "/etc/kea-subnets/kea-dhcp4.subnets"?>
    "loggers": [
    {
        "name": "kea-dhcp4",
        "output_options": [
            {
                "output": "syslog"
            }
        ],
        "severity": "INFO",
        "debuglevel": 10
    }
  ]
}
}
```

The provided configuration file starts up a very bare, non-functional, DHCP service.  

/etc/kea-ddns/kea-dhcp4.ddns
/etc/kea-option-data/kea-dhcp4.options
/etc/kea-subnets/kea-dhcp4.subnets


