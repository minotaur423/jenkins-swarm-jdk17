FROM openjdk:17-jdk-bullseye

USER root

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Add sudo and other package
RUN apt-get update && apt-get install sudo

# Add needed libraries
RUN apt-get install -qqy openjfx curl wget gnupg2

# Jenkins home is volume so it can be persisted
VOLUME /var/jenkins_home

# Set up Jenkins users and directories
RUN /usr/sbin/groupadd -g 1000 jenkins && /usr/sbin/groupadd -g 988 docker && \
    /usr/sbin/useradd -d /var/jenkins_home -u 1000 -g 1000 -G docker jenkins
ENV JENKINS_HOME=/var/jenkins_home

# Install and configure Jenkins Swarm Client
COPY ./run.sh /run.sh
RUN chmod +x /run.sh
ENV SWARM_CLIENT_VERSION=3.49
ADD https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_CLIENT_VERSION}/swarm-client-${SWARM_CLIENT_VERSION}.jar /usr/share/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar
RUN chmod 644 /usr/share/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar

# Install Node Version Manager (NVM), Node version 18.20.5 LTS and latest
#ENV NVM_DIR=/usr/local/nvm
#RUN mkdir $NVM_DIR
#ENV NODE_VERSION=v18.20.5
#RUN curl --silent -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

#RUN source $NVM_DIR/nvm.sh \
#  && nvm install $NODE_VERSION \
#  && nvm alias default $NODE_VERSION \
#  && nvm install node \
#  && nvm use default

# Install Yarn
RUN apt-get update && apt-get install -y apt-utils apt-transport-https
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -q -y install yarn

# Install Docker
RUN apt-get update -qq
RUN apt-get install -qqy apt-transport-https ca-certificates gnupg2 software-properties-common
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository "deb [arch=arm64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
RUN apt-get update -qq
RUN apt-get install -y docker-ce docker-ce-cli containerd.io

USER jenkins

# Run Jenkins Swarm Client
ENTRYPOINT ["/run.sh"]

