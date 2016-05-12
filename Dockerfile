################################################################################
# Base image
################################################################################

FROM nginx

################################################################################
# Build instructions
################################################################################

# Remove default nginx configs.
RUN rm -f /etc/nginx/conf.d/*

# Update packages
RUN apt-get clean && apt-get update

RUN apt-get install -my \
  supervisor \
  curl \
  wget

# Add PHP 7.0 package
RUN echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list
RUN wget https://www.dotdeb.org/dotdeb.gpg
RUN apt-key add dotdeb.gpg
RUN apt-get update

# Install packages
RUN apt-get install -my \
  php7.0-common \
  php7.0-json \
  php7.0 \
  php7.0-curl \
  php7.0-fpm \
  php7.0-gd \
  php7.0-memcached \
  php7.0-mysql \
  php7.0-mcrypt \
  php7.0-sqlite \
  php7.0-xdebug

# Run php as root
RUN sed -i "s/user = www-data/user = root/" /etc/php/7.0/fpm/pool.d/www.conf
RUN sed -i "s/group = www-data/group = root/" /etc/php/7.0/fpm/pool.d/www.conf

## Pass all docker environment
RUN sed -i '/^;clear_env = no/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf

# Get access to FPM-ping page /ping
RUN sed -i '/^;ping\.path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf
# Get access to FPM_Status page /status
RUN sed -i '/^;pm\.status_path/s/^;//' /etc/php/7.0/fpm/pool.d/www.conf

# Create sock
RUN mkdir /run/php/
RUN touch /run/php/php7.0-fpm.sock

# Copy configurations
COPY conf/nginx.conf /etc/nginx/
COPY conf/supervisord.conf /etc/supervisor/conf.d/
COPY conf/php.ini /etc/php/7.0/fpm/conf.d/40-custom.ini

################################################################################
# Volumes
################################################################################

VOLUME ["/var/www", "/etc/nginx/conf.d"]

################################################################################
# Ports
################################################################################

EXPOSE 80 443 9000

################################################################################
# Entrypoint
################################################################################

ENTRYPOINT ["/usr/bin/supervisord"]
