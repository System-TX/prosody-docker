################################################################################
# Build a dockerfile for Prosody XMPP server
# Based on ubuntu
################################################################################

FROM debian:9

MAINTAINER Prosody Developers <developers@prosody.im>

# Some dependencies in stretch are not suitable for Prosody 0.11.x, so add our repo
RUN echo "deb http://packages.prosody.im/debian stretch main" > /etc/apt/sources.list.d/prosody.list
ADD prosody_packages.gpg /etc/apt/trusted.gpg.d/prosody.gpg
RUN chmod a+r /etc/apt/trusted.gpg.d/prosody.gpg

# Install dependencies
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        lsb-base \
        adduser \
        libidn11 \
        libssl1.1 \
        lua-bitop \
        lua-dbi-mysql \
        lua-dbi-postgresql \
        lua-dbi-sqlite3 \
        lua-event \
        lua-expat \
        lua-filesystem \
        lua-sec \
        lua-socket \
        lua-zlib \
        lua5.1 \
        lua5.2 \
        openssl \
        ca-certificates \
        ssl-cert \
    && rm -rf /var/lib/apt/lists/*

# Install and configure prosody
COPY ./prosody.deb /tmp/prosody.deb
RUN dpkg -i /tmp/prosody.deb \
    && sed -i '1s/^/daemonize = false;\n/' /etc/prosody/prosody.cfg.lua \
    && perl -i -pe 'BEGIN{undef $/;} s/^log = {.*?^}$/log = {\n    {levels = {min = "info"}, to = "console"};\n}/smg' /etc/prosody/prosody.cfg.lua

RUN mkdir -p /var/run/prosody && chown prosody:prosody /var/run/prosody

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 80 443 5222 5269 5347 5280 5281
USER prosody
ENV __FLUSH_LOG yes
CMD ["prosody"]
