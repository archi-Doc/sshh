# docker buildx build --pull --no-cache -f ./sshh.mariadb.Dockerfile --platform=linux/amd64 -t sshh.mariadb .
FROM archidoc422/sshh:latest

RUN apt-get update \
  && apt-get install -yq --no-install-recommends mariadb-client

RUN apt-get clean autoclean && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
