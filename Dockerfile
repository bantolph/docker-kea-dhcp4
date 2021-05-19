FROM ubuntu:focal
MAINTAINER Filmon <filmon@hissing-skuz.de>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8

RUN apt-get -qqqy update
RUN apt-get -qqqy install apt-utils software-properties-common dctrl-tools

RUN apt-get -qqqy update && apt-get -qqqy dist-upgrade && apt-get -qqqy install kea-dhcp4-server kea-ctrl-agent kea-admin kea-common 


RUN mkdir -p /etc/kea && chown root:_kea /etc/kea/ && chmod 755 /etc/kea
RUN mkdir -p /etc/kea-dhcp4 && chown root:_kea /etc/kea-dhcp4/ && chmod 755 /etc/kea-dhcp4
RUN mkdir -p /etc/kea-ddns && chown root:_kea /etc/kea-ddns/ && chmod 755 /etc/kea-ddns
RUN mkdir -p /etc/kea-subnets && chown root:_kea /etc/kea-subnets/ && chmod 755 /etc/kea-subnets
RUN mkdir -p /etc/kea-option-data && chown root:_kea /etc/kea-option-data/ && chmod 755 /etc/kea-option-data
RUN mkdir -p /var/log/kea && chown _kea:_kea /var/log/kea && chmod 755 /var/log/kea
RUN mkdir -p /run/kea && chown _kea:_kea /run/kea && chmod 755 /run/kea

VOLUME ["/etc/kea-subnets"]

ENV CONTROL_AGENT_PORT 8000
ENV CONTROL_AGENT_HOST 0.0.0.0

EXPOSE 67/udp $CONTROL_AGENT_PORT/tcp

COPY kea-dhcp4.conf /etc/kea-dhcp4/kea-dhcp4.conf
RUN chown _kea:_kea /etc/kea-dhcp4/kea-dhcp4.conf
RUN chmod 664 /etc/kea-dhcp4/kea-dhcp4.conf
COPY kea-dhcp4.ddns /etc/kea-ddns/kea-dhcp4.ddns
RUN chown _kea:_kea /etc/kea-ddns/kea-dhcp4.ddns
RUN chmod 664 /etc/kea-ddns/kea-dhcp4.ddns
COPY kea-dhcp4.options /etc/kea-option-data/kea-dhcp4.options
RUN chown _kea:_kea /etc/kea-option-data/kea-dhcp4.options
RUN chmod 664 /etc/kea-option-data/kea-dhcp4.options
COPY kea-dhcp4.subnets /etc/kea-subnets/kea-dhcp4.subnets
RUN chown _kea:_kea /etc/kea-subnets/kea-dhcp4.subnets
RUN chmod 664 /etc/kea-subnets/kea-dhcp4.subnets

RUN mkdir -p /etc/kea-ctrl-agent
COPY  kea-ctrl-agent.conf.tmpl /etc/kea-ctrl-agent/kea-ctrl-agent.conf.tmpl

COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]

CMD ["/usr/sbin/kea-dhcp4", "-c", "/etc/kea-dhcp4/kea-dhcp4.conf"]
