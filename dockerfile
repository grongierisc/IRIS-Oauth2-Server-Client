FROM store/intersystems/irishealth:2019.3.0.308.0-community
LABEL maintainer="Guillaume Rongier <guillaume.rongier@intersystems.com>"

# Varaibles
ARG link
ARG port
ENV _HTTPD_DIR /etc/apache2

USER root

# Install GateWay
RUN apt-get update


RUN apt-get install -y apache2 debconf-utils sudo && a2enmod ssl && \
/bin/echo -e $ISC_PACKAGE_MGRUSER\\tALL=\(ALL\)\\tNOPASSWD: ALL >> /etc/sudoers &&\
sudo -u $ISC_PACKAGE_MGRUSER sudo echo enabled passwordless sudo-ing for $ISC_PACKAGE_MGRUSER

# Generate self signed certificate
RUN echo '* libraries/restart-without-asking boolean true' | debconf-set-selections && apt-get install -y openssl 
RUN mkdir $_HTTPD_DIR/ssl && openssl req -x509 -nodes -days 1 -newkey rsa:2048 -subj /CN=* -keyout $_HTTPD_DIR/ssl/server.key -out $_HTTPD_DIR/ssl/server.crt

#Enable CSPGateway
COPY ./cspgateway/ /opt/cspgateway/bin

COPY httpd-csp.conf $_HTTPD_DIR/sites-available

RUN a2ensite httpd-csp && update-rc.d apache2 enable

USER irisowner