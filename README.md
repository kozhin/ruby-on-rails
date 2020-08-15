# Ruby on Rails with Alpine Linux

> for Docker lightweight containers - image size is less than 500 Mb

Project contains both Ruby on Rails and Ruby on Rails + NodeJS images. Every pair is available for development and production. In production we don't install Ruby on Rails. The framework is expected to be installed within a specific application.

See samples folder for more examples.

## Building images

If you want Ruby on Rails only application, use the following command to build images:

```en
docker build -t rails:latest-dev -f dev.Dockerfile .
docker build -t rails:latest -f prod.Dockerfile .
```

If you want Ruby on Rails application with NodeJS support, use the following command to build images:

```en
docker build -t rails:latest-nodejs-dev -f dev.nodejs.Dockerfile .
docker build -t rails:latest-nodejs -f prod.nodejs.Dockerfile .
```

## How to use in apps

```en
# add to your Dockerfile
FROM <your docker registry URL>/rails:latest-dev
# or
FROM <your docker registry URL>rails:latest
# or
FROM <your docker registry URL>/rails:latest-nodejs-dev
# or
FROM <your docker registry URL>/rails:latest-nodejs
```

## Updating images

In order to update images change RAILS_VERSION variable in .gitlab-ci.yml.

Some production libraries must be updated using variables inside prod.Dockerfile and prod.nodejs.Dockerfile. 
