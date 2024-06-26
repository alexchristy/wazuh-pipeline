FROM wazuh/wazuh-manager:4.8.0

#=========================================#
#=== CHANGE THIS TO YOUR PIPELINE REPO ===#
#=========================================#
ENV PIPELINE_REPO=https://github.com/alexchristy/wazuh-pipeline.git
#=========================================#

ENV WAZUH_TEST_REPO=https://github.com/alexchristy/WazuhTest.git

WORKDIR /root

# Clone repos
RUN yum install git iproute golang -y 
RUN git clone $PIPELINE_REPO wazuh_pipeline
RUN git clone $WAZUH_TEST_REPO wazuh_test

# Install WazuhTest framework
WORKDIR /root/wazuh_test
RUN go build .
RUN chmod 751 WazuhTest
RUN cp ./WazuhTest /usr/bin

WORKDIR /root/wazuh_pipeline

RUN chmod +x ./*.sh

ENTRYPOINT ["/bin/sh", "/root/wazuh_pipeline/main.sh"]