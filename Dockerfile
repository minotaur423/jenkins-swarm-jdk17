FROM docker.io/redhat/ubi8-minimal:8.5-230

USER root

# Jenkins home is volume so it can be persisted
VOLUME /var/jenkins_home

# Set up Jenkins users and directories
RUN /usr/sbin/groupadd -g 1000 jenkins && /usr/sbin/groupadd -g 988 docker && \
    /usr/sbin/useradd -d /var/jenkins_home -u 1000 -g 1000 -G docker jenkins
ENV JENKINS_HOME=/var/jenkins_home

# Install and configure Jenkins Swarm Client
COPY ./run.sh /run.sh
RUN chmod +x /run.sh
ENV SWARM_CLIENT_VERSION=3.48
ADD https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_CLIENT_VERSION}/swarm-client-${SWARM_CLIENT_VERSION}.jar /usr/share/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar
RUN chmod 644 /usr/share/jenkins/swarm-client-${SWARM_CLIENT_VERSION}.jar

USER jenkins

# Run Jenkins Swarm Client
ENTRYPOINT ["/run.sh"]

