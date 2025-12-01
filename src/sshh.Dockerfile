FROM debian:trixie-slim

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends sudo vim-tiny openssh-server rsync cron \
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd
RUN echo "root:abcd" | sudo chpasswd

EXPOSE 2222
ADD ./src/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

