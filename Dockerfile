FROM ubuntu as pre-stage
WORKDIR /prep

# Install OpenJDK-14
RUN apt-get update && \
    apt-get install -y openjdk-14-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Setup JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/java-14-openjdk-amd64/
RUN export JAVA_HOME

# get fuseki
RUN apt-get update && apt-get install -y wget
RUN apt-get install -y git && apt-get install unzip

RUN wget -q https://hobbitdata.informatik.uni-leipzig.de/basilisk-demo/fuseki.zip && unzip fuseki.zip 

# get code from basilisk-frontend.git
RUN git clone https://github.com/dice-group/basilisk-frontend

# build stage
FROM node:lts-alpine as build-stage
WORKDIR /app
COPY --from=pre-stage /prep /app
RUN cd basilisk-frontend && npm install && npm run build

# production-stage
FROM nginx:stable-alpine as production-stage
WORKDIR /prod
COPY --from=pre-stage /prep /prod
COPY --from=build-stage /app/basilisk-frontend/dist /usr/share/nginx/html
EXPOSE 80

ADD run.sh /usr/local/bin/run.sh
RUN chmod 777 /usr/local/bin/run.sh
CMD /usr/local/bin/run.sh
# CMD ["nginx", "-g", "daemon off;"]