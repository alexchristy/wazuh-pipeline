FROM wazuh/wazuh-manager:4.8.0

ENV REPO=https://github.com/alexchristy/wazuh-pipeline.git

WORKDIR /root

RUN yum install git iproute -y && \
    git clone $REPO wazuh_pipeline

WORKDIR /root/wazuh_pipeline

# Delay until Wazuh manager is fully started
RUN sh start_delay.sh

RUN sh rule_decoder_installer.sh