FROM php:7.2-apache as builder
RUN echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
    && apt-get update
RUN apt-get install -y curl gnupg2 apt-transport-https ca-certificates \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list \
       > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools unixodbc-dev \
    && pecl install sqlsrv pdo_sqlsrv


FROM php:7.2-apache
RUN echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy \
    && apt-get update
RUN apt-get install -y curl gnupg2 apt-transport-https ca-certificates \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list \
       > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools
RUN apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && a2enmod rewrite
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/etc/ /usr/local/etc/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/local/sbin/ /usr/local/sbin/
COPY php-config/mssql-odbc.ini /usr/local/etc/php/conf.d/
ENV PATH="/opt/mssql-tools/bin:${PATH}"
