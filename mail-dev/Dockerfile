FROM ubuntu:18.04

LABEL maintainer="Nick Vissari <nvissari@hcpss.org>"

ENV TZ America/New_York

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
      postfix \
      mutt \
      dumb-init

COPY ./conf/ /etc/postfix/

COPY docker-entrypoint.sh /

ENTRYPOINT [ "dumb-init", "/docker-entrypoint.sh" ]
