
FROM phusion/baseimage:latest

RUN rm -f /etc/service/sshd/down

RUN set -eux; \
	apt-get update && apt-get install -y \
		btrfs-tools  \
		e2fsprogs \
		e2fsprogs \
		iptables \
		xz-utils \
		wget \
		apt-transport-https \
    	ca-certificates \
    	iputils-ping \
    	curl \
    	gnupg2 \
    	software-properties-common \
    	python \
    	python-pip \
    	dnsutils \
    	net-tools \
    	htop \
		pigz; \
	pip install docker;

RUN set -x \
	&& addgroup --system dockremap \
	&& adduser --system dockremap \
	&& adduser dockremap dockremap \
	&& echo 'dockremap:165536:65536' >> /etc/subuid \
	&& echo 'dockremap:165536:65536' >> /etc/subgid

RUN wget -qO- https://get.docker.com/ | sh

# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 37498f009d8bf25fbb6199e8ccd34bed84f2874b

RUN set -eux; \
	wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
	chmod +x /usr/local/bin/dind

COPY dockerd-entrypoint.sh /usr/local/bin/

VOLUME /var/lib/docker
EXPOSE 2375


RUN mkdir /etc/service/dockerd
COPY dockerd-entrypoint.sh /etc/service/dockerd/run
RUN chmod +x /etc/service/dockerd/run

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD ["/sbin/my_init"]