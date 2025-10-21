FROM ghcr.io/hayao0819/sgxsdk-docker-image:jammy-a833dba

WORKDIR /root
 RUN <<EOF
apt-get update && apt-get install -y build-essential git 
source /opt/intel/sgxsdk/environment
git clone https://github.com/cBioLab/helloSGX
cd helloSGX
make
EOF

ENTRYPOINT [ "./helloSGX/app" ]
