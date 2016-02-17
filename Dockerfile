FROM ubuntu:latest
############################################################
# Dockerfile to build developer environment for java war
# Based on Ubuntu
############################################################
MAINTAINER jasonzhuyx

# Update Ubuntu
RUN apt-get update && apt-get -y upgrade

# Update the APT cache
RUN sed -i.bak 's/main$/main universe/' /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y

# Install and setup project dependencies
RUN apt-get install -y curl wget
RUN locale-gen en_US en_US.UTF-8

# prepare for Java download
RUN apt-get install -y software-properties-common

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# grab oracle java (auto accept licence)
RUN echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN add-apt-repository -y ppa:webupd8team/java
RUN apt-get update
RUN apt-get install -y oracle-java8-installer

# Install tomcat
RUN apt-get -y install tomcat7
RUN echo "JAVA_HOME=$JAVA_HOME" >> /etc/default/tomcat7
ENV CATALINA_HOME /usr/share/tomcat7
ENV CATALINA_BASE /var/lib/tomcat7

# Install Maven
RUN apt-get install -y maven

# Copy the project
COPY ./ /src
WORKDIR /src

# Build the project
RUN mvn clean install

# deploy the project to http://localhost:8080/hello-world-java-1.0/
RUN mv $CATALINA_BASE/webapps/ROOT $CATALINA_BASE/webapps/ROOT.backup
RUN cp build/hello-world-java-1.0.war $CATALINA_BASE/webapps/ROOT.war

EXPOSE 8080

CMD [ "/usr/share/tomcat7/bin/catalina.sh", "run" ]
