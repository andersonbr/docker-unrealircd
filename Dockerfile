FROM debian:buster-slim
MAINTAINER Anderson Calixto <andersonbr@gmail.com>

ENV UNREAL_VERSION=5.0.3.1
ENV ANOPE_VERSION=2.0.7

# dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
        && apt update \
        && apt upgrade -y \
        && apt install -y \
                build-essential \
                cmake \
                file \
                gcc \
                gnupg \
                libcurl4-openssl-dev \
                libgcrypt20 \
                libgcrypt20-dev \
                libssl-dev \
                make \
                openssl \
                wget \
                zlib1g \
                zlib1g-dev \
                zlibc \
                default-libmysqlclient-dev \
        && gpg --keyserver keys.gnupg.net --recv-keys 0xA7A21B0A108FF4A9 \
        && apt-get clean \
        ;

# user and group
RUN groupadd -r unreal \
        && useradd -r -g unreal unreal \
        && mkdir -p /home/unreal \
        && chown unreal:unreal /home/unreal \
        ;

# unrealircd
USER unreal
ADD config.settings /tmp
RUN cd /tmp \
        && gpg --keyserver keys.gnupg.net --recv-keys 0xA7A21B0A108FF4A9 \
        && wget "https://www.unrealircd.org/unrealircd4/unrealircd-${UNREAL_VERSION}.tar.gz" \
        && wget "https://www.unrealircd.org/unrealircd4/unrealircd-${UNREAL_VERSION}.tar.gz.asc" \
        && gpg --verify unrealircd-${UNREAL_VERSION}.tar.gz.asc unrealircd-${UNREAL_VERSION}.tar.gz \
        && tar xvzf unrealircd-${UNREAL_VERSION}.tar.gz \
        && cd unrealircd-${UNREAL_VERSION} \
        && cp /tmp/config.settings . \
        && ./Config -quick -nointro \
        ;

# anope
ADD config.cache /tmp/

RUN cd /tmp \
        && wget "https://github.com/anope/anope/releases/download/${ANOPE_VERSION}/anope-${ANOPE_VERSION}-source.tar.gz" \
        && tar xvzf anope-${ANOPE_VERSION}-source.tar.gz \
        && cd anope-${ANOPE_VERSION}-source \
        && cp /tmp/config.cache . \
        && printf "m_mysql.cpp\nm_ssl_openssl.cpp\nm_sql_oper.cpp\nm_sql_authentication.cpp\nm_sql_log.cpp\nq\n"|./extras \
        && ./Config -quick \
        && cd build \
        && make \
        && make install \
        ;

# clean
USER root
RUN export DEBIAN_FRONTEND=noninteractive \
        && apt remove -y build-essential \
                cmake \
                file \
                gcc \
                gnupg \
                libcurl4-openssl-dev \
                libgcrypt20-dev \
                libssl-dev \
                make \
                wget \
                zlib1g-dev \
                default-libmysqlclient-dev \
        && apt-get clean \
        && rm -rf /tmp/config.settings \
        && rm -rf /tmp/config.cache \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
        ;

# command
USER unreal
CMD /home/unreal/unrealircd/unrealircd start
