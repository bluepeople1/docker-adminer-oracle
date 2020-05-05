FROM adminer

# Switch to the root user so we can install additional packages.
USER root

ENV LD_LIBRARY_PATH /usr/local/instantclient
ENV ORACLE_HOME /usr/local/instantclient

# ORACLE EXTENSION
RUN apk add php7-pear php7-dev gcc musl-dev libnsl libaio make &&\
    curl -o /tmp/basic.zip https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip && \
    curl -o /tmp/sdk.zip https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip && \
    unzip -d /usr/local/ /tmp/basic.zip && \
    unzip -d /usr/local/ /tmp/sdk.zip && \
    ln -s /usr/local/instantclient_19_6 ${ORACLE_HOME} && \
    ln -s /usr/local/instantclient/lib* /usr/lib && \
    ln -sfn /usr/lib//libclntsh.so.* /usr/lib/libclntsh.so && \
    ln -s /usr/lib/libnsl.so.2.0.0  /usr/lib/libnsl.so.1
#     ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

RUN echo "instantclient,${ORACLE_HOME}" | pecl install oci8 \
    && docker-php-ext-enable oci8 \
    && docker-php-ext-configure pdo_oci --with-pdo-oci=instantclient,/usr/local/instantclient \
    && docker-php-ext-install pdo_oci
    
RUN apk del php7-pear php7-dev gcc musl-dev && \
    rm -rf /tmp/*.zip /var/cache/apk/* /tmp/pear/

# Adjust permissions on /etc/passwd so writable by group root.
RUN chmod g+w /etc/passwd

## Adjust permissions on home directory so writable by group root.
#RUN	addgroup -S 1001 \
#&&	adduser -S -G 1001 1001 \
#&&	chown -R 1001:1001 /var/www/html

WORKDIR /var/www/html

USER adminer
