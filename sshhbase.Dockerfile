# docker buildx build --no-cache -f ./sshhbase.Dockerfile --platform=linux/amd64 -t sshhbase .
FROM debian:bookworm-slim

RUN apt-get update && \
  DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends sudo vim-tiny openssh-server rsync cron && \
  apt-get clean autoclean && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd
RUN echo "root:abcd" | sudo chpasswd

