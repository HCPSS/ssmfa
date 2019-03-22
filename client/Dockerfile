FROM node:10 AS build

ENV DEBIAN_FRONTEND noninteractive

ENV NODE_ROOT /app/

RUN mkdir -p $NODE_ROOT

WORKDIR $NODE_ROOT

COPY . .

RUN npm install -g @angular/cli && \
    npm install && \
    ng build --prod

FROM nginx:alpine

LABEL maintainer="Nick Vissari <nvissari@hcpss.org>"

WORKDIR /usr/share/nginx/html/

COPY --from=build /app/dist/ssmfa/ .

COPY nginx.conf /etc/nginx/conf.d/default.conf
