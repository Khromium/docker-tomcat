# Dockerfile for java / tomcat and Japanese
FROM arm64v8/ubuntu:16.04

######################################################################################################################################################
# Set up Japanese
######################################################################################################################################################
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y tzdata \
 && echo "Asia/Tokyo" > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata \
 && apt-get install -y language-pack-ja \
 && update-locale LANG=ja_JP.UTF-8 \
 && apt-get install -y software-properties-common vim wget curl unzip zip build-essential python git bash-completion fonts-ipaexfont-gothic \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
ENV LANG ja_JP.UTF-8

######################################################################################################################################################
# Set up Java(lastest)
######################################################################################################################################################
RUN apt-get update && \
    apt-get install -y --force-yes openjdk-8-jdk && \
    echo "===> clean up..."  && \
    apt-get clean
######################################################################################################################################################
# Set up Tomcat
######################################################################################################################################################
RUN apt-get update && \
    apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV TOMCAT_MAJOR_VERSION 8
ENV TOMCAT_MINOR_VERSION 8.5.5
ENV CATALINA_HOME /tomcat

# INSTALL TOMCAT
RUN wget -q https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz && \
    wget -qO- https://archive.apache.org/dist/tomcat/tomcat-${TOMCAT_MAJOR_VERSION}/v${TOMCAT_MINOR_VERSION}/bin/apache-tomcat-${TOMCAT_MINOR_VERSION}.tar.gz.md5 | md5sum -c - && \
    tar zxf apache-tomcat-*.tar.gz && \
    rm apache-tomcat-*.tar.gz && \
    mv apache-tomcat* /tomcat

RUN chmod -R 777 /tomcat/webapps

RUN \
  apt-get update && \
  apt-get autoremove -y && \
  apt-get clean allEXPOSE 8080


# ==== dumb-init ====
RUN apt-get update && \
    apt-get install -y --force-yes python-pip && \
    apt-get clean && \
    pip install --no-cache-dir dumb-init

# ==== environment ====
RUN rm -rf /tomcat/webapps/ROOT \
  && update-ca-certificates -f \


######################################################################################################################################################
# Set up Tomcat
######################################################################################################################################################
EXPOSE 8080
# Define default command.
CMD [ "dumb-init", "/tomcat/bin/catalina.sh", "run" ]
