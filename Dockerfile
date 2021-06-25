ARG DEBIAN_VERSION=buster-slim
ARG DOCKER_VERSION=19.03.13

FROM docker:${DOCKER_VERSION} AS docker-cli

FROM debian:${DEBIAN_VERSION}

ENV DOCKER_BUILDKIT=1
ENV NODE_VERSION=14.15.0
ENV NVM_DIR=/opt/nvm

# Install Debian packages and jre 11
RUN mkdir -p /usr/share/man/man1 /opt/nvm  && \
    apt-get update -y && \
    apt-get install -y --no-install-recommends sudo ca-certificates make git openssh-client curl tzdata locales unzip jq && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -r /var/cache/* /var/lib/apt/lists/*

COPY --from=docker-cli /usr/local/bin/docker /usr/local/bin/docker

# Install Node
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh | bash && \
    . "${NVM_DIR}/nvm.sh" && nvm install ${NODE_VERSION} && \
    . "${NVM_DIR}/nvm.sh" && nvm use v${NODE_VERSION} && \
    . "${NVM_DIR}/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Install semantic-release
RUN npm install -g semantic-release \
    @semantic-release/changelog \
    @semantic-release/git \
    @semantic-release/github \
    @semantic-release/exec
