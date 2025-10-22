FROM ghcr.io/hayao0819/sgxsdk-docker-image:jammy-a833dba

WORKDIR /root
RUN <<EOF
apt-get update
apt-get install -y --no-install-recommends build-essential git 
. /opt/intel/sgxsdk/environment
git clone https://github.com/cBioLab/helloSGX
rm -rf /var/lib/apt/lists/*
EOF

WORKDIR /root/helloSGX
RUN make

ENTRYPOINT [ "/root/helloSGX/app" ]
