FROM wazuh/wazuh-manager:4.8.0

ENV REPO=https://github.com/alexchristy/wazuh-pipeline.git

WORKDIR /root

RUN yum install git iproute -y && \
    git clone $REPO wazuh_pipeline

WORKDIR /root/wazuh_pipeline

RUN chmod +x ./*.sh

ENTRYPOINT ["/bin/sh", "/root/wazuh_pipeline/main.sh"]