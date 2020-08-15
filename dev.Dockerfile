# Set initial image
FROM kozhin/ruby:latest

# Set maintainer and info for image
LABEL Description="This image contains Ruby language and Ruby on Rails framework for development" \
      Vendor="CodedRed" \
      Version="1.0.0" \
      Maintainer="Konstantin Kozhin <https://github.com/kozhin>"

# Define arg variables
ARG RAILS_VERSION

# Set Ruby on Rails verstion to install
ENV RAILS_VERSION $RAILS_VERSION

# Install Vim colors
RUN mkdir -p ./.vim/colors
COPY vim/.vimrc ./
COPY vim/monokai.vim ./.vim/colors

# Install Ruby on Rails
RUN PACKAGES="curl bash" && \
    BUILD_PACKAGES="build-base libxml2-dev sqlite-dev postgresql-dev" && \
# Install packages
    apk add --no-cache --update ${PACKAGES} ${BUILD_PACKAGES} && \
# Install gems
    gem install bundler rails:$RAILS_VERSION --no-document && \
# Clean up packages
    apk del ${BUILD_PACKAGES} && \
    rm -rf /var/cache/apk/* \
           /tmp/*

# Set entrypoint
CMD ["rails"]
