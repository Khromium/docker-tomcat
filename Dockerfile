# Dockerfile for java / tomcat and Japanese
FROM ubuntu:16.04

######################################################################################################################################################
# Set up Japanese
######################################################################################################################################################
RUN echo "Asia/Tokyo" > /etc/timezone \
 && dpkg-reconfigure -f noninteractive tzdata \
 && apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y language-pack-ja \
 && update-locale LANG=ja_JP.UTF-8 \
 && apt-get install -y software-properties-common vim wget curl unzip zip build-essential python git bash-completion fonts-ipaexfont-gothic \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*
ENV LANG ja_JP.UTF-8

######################################################################################################################################################
# Set up Java(lastest)
######################################################################################################################################################
RUN echo "deb http://archive.ubuntu.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list

RUN \
    echo "===> add webupd8 repository..."  && \
    echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee /etc/apt/sources.list.d/webupd8team-java.list  && \
    echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list  && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886  && \
    apt-get update  && \
    \
    \
    echo "===> install Java"  && \
    echo debconf shared/accepted-oracle-license-v1-1 select true | debconf-set-selections  && \
    echo debconf shared/accepted-oracle-license-v1-1 seen true | debconf-set-selections  && \
    DEBIAN_FRONTEND=noninteractive  apt-get install -y --force-yes oracle-java8-installer oracle-java8-set-default  && \
    \
    \
    echo "===> clean up..."  && \
    rm -rf /var/cache/oracle-jdk8-installer  && \
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
ADD https://github.com/Yelp/dumb-init/releases/download/v1.0.0/dumb-init_1.0.0_amd64 \
      /usr/local/bin/dumb-init

# ==== environment ====
RUN rm -rf /tomcat/webapps/ROOT \
  && update-ca-certificates -f \
  && chmod +x /usr/local/bin/dumb-init


######################################################################################################################################################
# Set up Tomcat
######################################################################################################################################################
EXPOSE 8080
# Define default command.
CMD [ "/usr/local/bin/dumb-init", "/tomcat/bin/catalina.sh", "run" ]
