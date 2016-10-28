FROM debian:latest

RUN apt update && apt install -y clamav git libpcre3-dev build-essential libdb-dev libopendmarc-dev python-setuptools  libspf2-dev libsasl2-dev libldap2-dev libdkim-dev libgnutls28-dev pkg-config libidn11-dev libpam-dev && \
    cd /opt && git clone https://github.com/LynxChaus/libsrs-alt && cd libsrs-alt && ./configure && make && make install && cp /usr/local/lib/libsrs* /usr/lib/ && \
    cd /opt && git clone https://github.com/exim/exim && mkdir -p exim/src/Local && useradd exim4

RUN apt install -y uuid-dev libgcrypt-dev libestr-dev flex dh-autoreconf bison python-docutils libxml2-dev && \
    cd /opt && git clone https://github.com/rsyslog/libfastjson && cd libfastjson && autoreconf -v --install && ./configure && make && make install && \
    git clone https://github.com/rsyslog/liblogging && cd liblogging && autoreconf -v --install && ./configure --disable-man-pages && make && make install && \
    git clone https://github.com/rsyslog/rsyslog && cd rsyslog && ./autogen.sh --enable-omstdout && make && make install && \
    git clone https://github.com/vrtadmin/clamav-devel && cd clamav-devel && ./configure --enable-libfreshclam --enable-experimental && make && make install && \
    mkdir -p /usr/local/share/clamav && chmod 777 /usr/local/share/clamav/ && ldconfig && \
    cd /usr/local/share/ca-certificates && \
    wget https://letsencrypt.org/certs/letsencryptauthorityx1.pem && mv letsencryptauthorityx1.pem letsencryptauthorityx1.crt && \
    wget https://letsencrypt.org/certs/letsencryptauthorityx2.pem && mv letsencryptauthorityx2.pem letsencryptauthorityx2.crt && \
    wget https://letsencrypt.org/certs/letsencryptauthorityx3.pem && mv letsencryptauthorityx3.pem letsencryptauthorityx3.crt && \
    wget https://letsencrypt.org/certs/letsencryptauthorityx4.pem && mv letsencryptauthorityx4.pem letsencryptauthorityx4.crt && \
    wget https://letsencrypt.org/certs/isrgrootx1.pem && mv isrgrootx1.pem isrgrootx1.crt && update-ca-certificates

ADD Makefile /opt/exim/src/Local

RUN cd /opt/exim/src && make && make install && mkdir -p /var/spool/exim && mkdir -p /usr/lib/exim/lookups && ln -sf /dev/stdout /var/log/syslog && \
    rm -rf /var/lib/apt/lists/* && mkdir -p /run/php && mkdir /var/log/supervisor/ && /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout

WORKDIR /usr/bin

ADD supervisord.conf /etc/supervisord.conf
ADD rsyslog.conf /etc/rsyslog.conf

ADD freshclam.conf /usr/local/etc/
ADD clamd.conf /usr/local/etc/

ADD runclamd /opt

EXPOSE 25 465 587

CMD ["supervisord","-n","-c","/etc/supervisord.conf"]

