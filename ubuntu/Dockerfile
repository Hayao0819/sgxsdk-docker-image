ARG OS_CODE_NAME=noble

# https://download.01.org/intel-sgx/sgx-linux/2.26/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf

FROM ubuntu:${OS_CODE_NAME}

ARG OS_CODE_NAME
ARG OS_VER
ARG BUILD_VER
ARG SGX_SDK_VER

WORKDIR /root

RUN apt-get update && apt-get install -y \
    wget \
    gnupg2 \
    lsb-release \
    ca-certificates

# Intel SGX Application User
RUN echo "deb [signed-by=/etc/apt/keyrings/intel-sgx-keyring.asc arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu ${OS_CODE_NAME} main" | tee /etc/apt/sources.list.d/intel-sgx.list

RUN wget https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key && cat intel-sgx-deb.key | tee /etc/apt/keyrings/intel-sgx-keyring.asc > /dev/null

RUN apt-get update && apt-get install -y libsgx-quote-ex libsgx-dcap-ql libsgx-urts-dbgsym libsgx-enclave-common-dbgsym libsgx-dcap-ql-dbgsym libsgx-dcap-default-qpl-dbgsym
RUN apt-get update && apt-get install -y libsgx-urts libsgx-launch libsgx-enclave-common 
RUN apt-get update && apt-get install -y libsgx-dcap-default-qpl

# Intel SGX Application Developer
RUN apt-get install -y build-essential python-is-python3 git cmake
RUN wget https://download.01.org/intel-sgx/sgx-linux/${SGX_SDK_VER}/distro/ubuntu${OS_VER}-server/sgx_linux_x64_sdk_${SGX_SDK_VER}.${BUILD_VER}.bin
RUN chmod +x sgx_linux_x64_sdk_${SGX_SDK_VER}.${BUILD_VER}.bin && ./sgx_linux_x64_sdk_${SGX_SDK_VER}.${BUILD_VER}.bin --prefix=/opt/intel/sgx
RUN apt-get update && apt-get install -y libsgx-enclave-common-dev libsgx-dcap-ql-dev libsgx-dcap-default-qpl-dev 
# RUN apt-get update && apt-get install -y tee_appraisal_tool
RUN . /opt/intel/sgx/sgxsdk/environment && \
    echo "source /opt/intel/sgx/sgxsdk/environment" >> /root/.bashrc
