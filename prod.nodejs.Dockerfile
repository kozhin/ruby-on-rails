# Set initial image
FROM kozhin/ruby:latest-nodejs

# Set maintainer and info for image
LABEL Description="This image contains Ruby language, Nginx + Passenger for production" \
      Vendor="CodedRed" \
      Version="1.1.0" \
      Maintainer="Konstantin Kozhin <https://github.com/kozhin>"

# Define arg variables
ARG RAILS_VERSION
ARG NGINX_VERSION
ARG PASSENGER_VERSION

# Set Ruby on Rails verstion to install
ENV RAILS_VERSION $RAILS_VERSION
ENV NGINX_VERSION $NGINX_VERSION
ENV PASSENGER_VERSION $PASSENGER_VERSION

# Set env variables
ENV NGINX_SRC_PATH /src/nginx
ENV NGINX_PATH /opt/nginx
ENV PATH /src/passenger/bin:$PATH

# Install packages
RUN PACKAGES="bash curl pcre procps ca-certificates libstdc++" && \
    BUILD_PACKAGES="build-base linux-headers curl-dev pcre-dev ruby-dev zlib-dev libexecinfo-dev" && \
    apk add --no-cache --update ${PACKAGES} ${BUILD_PACKAGES} && \
    gem install rack rake --no-document && \
# Download and extract
    mkdir -p /opt && \
    mkdir -p /src && \
    cd /src && \
    curl -L http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -xzf - -C /src && \
    mv nginx-${NGINX_VERSION} nginx && \
    curl -L https://s3.amazonaws.com/phusion-passenger/releases/passenger-${PASSENGER_VERSION}.tar.gz | tar -xzf - -C /src && \
    mv passenger-${PASSENGER_VERSION} passenger && \
    export EXTRA_PRE_CFLAGS='-O' EXTRA_PRE_CXXFLAGS='-O' EXTRA_LDFLAGS='-lexecinfo' && \
# Compile Nginx + Passenger
    passenger-install-nginx-module --auto \
        --prefix=${NGINX_PATH} \
        --nginx-source-dir=${NGINX_SRC_PATH} \
        --extra-configure-flags=" \
        --with-file-aio \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-stream \
        --with-stream_ssl_module \
        --with-threads" && \
    passenger-config build-native-support && \
# Place nginx binary to executable path
    ln -s ${NGINX_PATH}/sbin/nginx /usr/sbin/nginx && \
    ln -s ${NGINX_PATH} /etc/nginx && \
    chmod o+x /root && \
# Send nginx logs to stdout
    ln -sf /dev/stdout ${NGINX_PATH}/logs/access.log && \
    ln -sf /dev/stderr ${NGINX_PATH}/logs/error.log && \
# Create app directory
    mkdir -p /app && \
# Clean up passenger src directory
    rm -rf /tmp/* && \
    mv /src/passenger/src/ruby_supportlib /tmp && \
    mv /src/passenger/src/nodejs_supportlib /tmp && \
    mv /src/passenger/src/helper-scripts /tmp && \
    rm -rf /src/passenger/src/* && \
    mv /tmp/* /src/passenger/src/ && \
# Clean up
    passenger-config validate-install --auto && \
    apk del ${BUILD_PACKAGES} && \
    rm -rf /var/cache/apk/* \
           /tmp/* \
           /src/nginx \
           /src/passenger/doc

# Copy configuration files for Nginx
COPY nginx/nginx.conf /etc/nginx/conf/
COPY nginx/application.conf /etc/nginx/conf/

# Set working folder
WORKDIR /app

# Expose port
EXPOSE 80 443

# Stop signal for container
STOPSIGNAL SIGTERM

# Command to execute
CMD ["nginx", "-g", "daemon off;"]
