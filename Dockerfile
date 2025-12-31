# Base Jenkins LTS image
FROM jenkins/jenkins:lts

USER root

# 1. Install Docker CLI (allows Jenkins to run Docker commands)
RUN apt-get update && apt-get install -y lsb-release \
    && curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc https://download.docker.com/linux/debian/gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
    https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y docker-ce-cli

# 2. Pre-install Jenkins Plugins (Blue Ocean, Docker Workflow, SonarQube)
# This removes the need to manually install them via the UI
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow sonar git"

USER jenkins