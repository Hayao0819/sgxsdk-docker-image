ARG OS_CODE_NAME=noble

# https://download.01.org/intel-sgx/sgx-linux/2.26/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf

FROM ubuntu:${OS_CODE_NAME}

ARG OS_CODE_NAME
ARG OS_VER
ARG BUILD_VER
ARG SGX_SDK_VER

WORKDIR /root

COPY "ubuntu-install.sh" .
COPY "versions.json" .
RUN bash ./ubuntu-install.sh && rm -f ./ubuntu-install.sh ./versions.json
