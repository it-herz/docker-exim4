FROM debian:latest

RUN apt update && apt install -y clamav git libpcre3-dev build-essential libdb-dev libopendmarc-dev libspf2-dev libsasl2-dev libldap2-dev libdkim-dev libgnutls28-dev pkg-config libidn11-dev libpam-dev && \
    cd /opt && git clone https://github.com/LynxChaus/libsrs-alt && cd libsrs-alt && ./configure && make && make install && cp /usr/local/lib/libsrs* /usr/lib/ && \
    cd /opt && git clone https://github.com/exim/exim && mkdir -p exim/src/Local && useradd exim4

ADD Makefile /opt/exim/src/Local

RUN cd /opt/exim/src && make && make install && mkdir -p /var/spool/exim && mkdir -p /usr/lib/exim/lookups && ln -sf /dev/stdout /var/log/syslog

WORKDIR /usr/bin

ENTRYPOINT /bin/bash

CMD [ "exim" "-bd" "-q15m"]

