FROM ubuntu:focal
MAINTAINER Filmon <filmon@hissing-skuz.de>

ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL C.UTF-8

RUN apt-get -qqqy update
RUN apt-get -qqqy install apt-utils software-properties-common dctrl-tools

RUN apt-get -qqqy update && apt-get -qqqy dist-upgrade && apt-get -qqqy install kea-dhcp4-server kea-ctrl-agent kea-admin kea-common 

VOLUME ["/etc/kea", "/var/log/kea"]

RUN mkdir -p /etc/kea && chown root:_kea /etc/kea/ && chmod 755 /etc/kea
RUN mkdir -p /var/log/kea && chown _kea:_kea /var/log/kea && chmod 755 /var/log/kea
RUN mkdir -p /run/kea && chown _kea:_kea /run/kea && chmod 755 /run/kea

EXPOSE 67/udp 8000/tcp

COPY wrapper.sh wrapper.sh
RUN chmod 755 wrapper.sh

#CMD ["/usr/sbin/kea-dhcp4", "-c", "/etc/kea/kea-dhcp4.conf"]
CMD ["./wrapper.sh"]
