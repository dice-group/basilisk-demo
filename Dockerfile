FROM ubuntu:20.04 as pre-stage
ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /prep

# Install required tools
RUN apt-get  update && \
    apt-get install -y unzip git wget

# get fuseki
RUN wget -q https://hobbitdata.informatik.uni-leipzig.de/basilisk-demo/fuseki.zip && unzip fuseki.zip

# get code from basilisk-frontend.git
RUN git clone https://github.com/dice-group/basilisk-frontend

# build stage
FROM node:lts-alpine as build-stage
WORKDIR /app
COPY --from=pre-stage /prep /app
RUN cd basilisk-frontend && npm install && npm run build

# production-stage
# TODO: use in both stages either lts-alpine or stable alpine?
FROM nginx:stable-alpine as production-stage
WORKDIR /prod

#install dependency for fuseki
RUN apk add openjdk11

# install fuseki and basilisk frontend files
COPY --from=pre-stage /prep /prod
# install fuseki and basilisk frontend files
COPY --from=build-stage /app/basilisk-frontend/dist /usr/share/nginx/html

# add script to run fuseki and basilisk-frontend
ADD run.sh /usr/local/bin/run.sh
RUN chmod 777 /usr/local/bin/run.sh

EXPOSE 80
EXPOSE 3030
CMD /usr/local/bin/run.sh