FROM node:10 as packages

RUN apt-get update && apt-get install -y dumb-init

FROM node:10

LABEL maintainer="Nick Vissari <nvissari@hcpss.org>"

COPY --from=packages /usr/bin/dumb-init /usr/bin/dumb-init

RUN npm install -g nodemon && mkdir /jwt && chown node:node /jwt

COPY ./ /home/node/app/

COPY ./docker-entrypoint.sh /

WORKDIR /home/node/app

RUN npm install

COPY daemonconfig /usr/bin/daemonconfig

CMD ["dumb-init", "/docker-entrypoint.sh"]
