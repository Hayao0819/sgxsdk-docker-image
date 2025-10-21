# Ubuntu

When building a Docker image, you must specify the OS version and SDK version.
For example:

```bash
docker build -t sgxsdk:22.04-2.26-100.0 --build-arg OS_CODE_NAME=jammy --build-arg OS_VER=22.04 --build-arg BUILD_VER=100.0 --build-arg SGX_SDK_VER=2.26 .
```

## List of argument

|SGX_SDK_VER|BUILD_VER|OS_CODE_NAME|OS_VER|
|---|---|---|---|
|2.26|100.0|noble|24.04|
|2.26|100.0|jammy|22.04|
|2.25|100.3|noble|24.04|
|2.25|100.3|jammy|22.04|
|2.24|100.3|jammy|22.04|
|2.23|100.2|jammy|22.04|
|2.22|100.3|jammy|22.04|
|2.21|100.1|jammy|22.04|
|2.20|100.4|jammy|22.04|
|2.19|100.3|jammy|22.04|
|2.18|100.3|jammy|22.04|
