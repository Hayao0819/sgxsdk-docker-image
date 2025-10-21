#!/usr/bin/env bash

set -eEuo pipefail

_os_code_name="${OS_CODE_NAME-""}"
_os_ver="${OS_VER-""}"
_sgx_sdk_ver="${SGX_SDK_VER-""}"
_build_ver="${BUILD_VER-""}"

_versions_file="$(dirname "$0")/versions.json"
_install_dcap=true
_install_dbgsym=true

_parse_arg() {
	while (("$#" > 0)); do
		case $1 in
		--os-code-name)
			_os_code_name="$2"
			shift 2
			;;
		--os-ver)
			_os_ver="$2"
			shift 2
			;;
		--sgx-sdk-ver)
			_sgx_sdk_ver="$2"
			shift 2
			;;
		--build-ver)
			_build_ver="$2"
			shift 2
			;;
		--no-dcap)
			_install_dcap=false
			shift 1
			;;
		--no-dbgsym)
			_install_dbgsym=false
			shift 1
			;;
		--versions)
			_versions_file="$2"
			shift 2
			;;
		--)
			shift 1
			break
			;;
		*)
			echo "Unknown argument: $1" >&2
			exit 1
			;;
		esac
	done
}

_detect_os() {
	# shellcheck disable=SC1091
	source /etc/os-release
	_os_code_name=${_os_code_name:-${VERSION_CODENAME-""}}
	_os_ver=${_os_ver:-${VERSION_ID-""}}

	if ! type apt-get >/dev/null 2>&1; then
		echo "Error: 'apt-get' is required but not installed. This script is intended for Ubuntu systems." >&2
		exit 1
	fi

}

_detect_versions() {

	if ! (apt-get update && apt-get install jq -y); then
		echo "Error: Failed to install 'jq'. Please ensure you have internet connectivity and try again." >&2
		exit 1
	fi

	if ! type jq >/dev/null 2>&1; then
		echo "Error: 'jq' is required but not installed. Please install 'jq' and try again." >&2
		exit 1
	fi

	if [[ -z "$_os_ver" ]] && [[ -z "$_os_code_name" ]]; then
		echo "Error: Either --os-ver or --os-code-name must be specified." >&2
		exit 1
	fi

	# detect OS version
	if [[ -z "$_os_code_name" ]]; then
		_os_code_name="$(
			jq "[ .[] | select (.OS_VER == \"$_os_ver\") ] | . [0].OS_CODE_NAME" "$_versions_file" --raw-output
		)"
	fi
	if [[ -z "$_os_ver" ]]; then
		_os_ver="$(
			jq "[ .[] | select (.OS_CODE_NAME == \"$_os_code_name\") ] | . [0].OS_VER" "$_versions_file" --raw-output
		)"
	fi

	if [[ -z "$_sgx_sdk_ver" ]] || [[ -z "$_build_ver" ]]; then
		_sgx_sdk_ver="$(
			jq "[ .[] | select (.OS_CODE_NAME == \"$_os_code_name\") ] | . [0].SGX_SDK_VER" "$_versions_file" --raw-output
		)"
		_build_ver="$(
			jq "[ .[] | select (.OS_CODE_NAME == \"$_os_code_name\") ] | . [0].BUILD_VER" "$_versions_file" --raw-output
		)"
	fi

	if [[ -z "$_sgx_sdk_ver" ]] || [[ -z "$_build_ver" ]]; then
		echo "Error: Could not detect SGX SDK version for OS code name '$_os_code_name'." >&2
		exit 1
	fi
}

_install_deps() {
	local _deps=(
		wget
		gnupg2
		lsb-release
		ca-certificates

		build-essential
		python-is-python3
		git
		cmake
	)

	apt-get install -y "${_deps[@]}"
}

_add_sgx_repo() {
	echo "deb [signed-by=/etc/apt/keyrings/intel-sgx-keyring.asc arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu ${_os_code_name} main" >/etc/apt/sources.list.d/intel-sgx.list
	wget -O - https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key >/etc/apt/keyrings/intel-sgx-keyring.asc
	apt-get update
}

_install_sgxpsw() {
	local _psw=(
		libsgx-quote-ex
		libsgx-dcap-ql
		libsgx-urts-dbgsym
		libsgx-enclave-common-dbgsym
		libsgx-dcap-ql-dbgsym
		libsgx-dcap-default-qpl-dbgsym
		libsgx-urts
		libsgx-launch
		libsgx-enclave-common
		libsgx-dcap-default-qpl
	)

	local _install_pkgs=()

	# _install_dbgsym=falseの場合、dbgsymパッケージを除外
	readarray -t _install_pkgs < <(
		printf '%s\n' "${_psw[@]}" |
			if [ "${_install_dbgsym}" = false ]; then
				grep -v '-dbgsym$'
			else
				cat
			fi |
			if [ "${_install_dcap}" = false ]; then
				grep -v 'dcap'
			else
				cat
			fi
	)
	echo "Installing SGX PSW packages: ${_install_pkgs[*]}"
	apt-get install -y "${_install_pkgs[@]}"
}
_download_sgxsdk() {
	local _tmpdir
	_tmpdir=$(mktemp -d)
	local _url="https://download.01.org/intel-sgx/sgx-linux/${_sgx_sdk_ver}/distro/ubuntu${_os_ver}-server/sgx_linux_x64_sdk_${_sgx_sdk_ver}.${_build_ver}.bin"

	_filename="sgx_linux_x64_sdk.bin"
	wget -O "${_tmpdir}/${_filename}" "${_url}" 2>/dev/null >/dev/null || {
		echo "Error: Failed to download SGX SDK from ${_url}" >&2
		exit 1
	}
	echo "${_tmpdir}/${_filename}"
}

_install_sgxsdk() {
	local _installer
	_installer=$(_download_sgxsdk)

	chmod +x "${_installer}"
	"${_installer}" --prefix=/opt/intel

	rm -rf "$(dirname "${_installer}")"
	apt-get install -y libsgx-enclave-common-dev libsgx-dcap-ql-dev libsgx-dcap-default-qpl-dev
}

_setup_environment() {
	ln -s /opt/intel/sgxsdk/environment /etc/profile.d/sgx_sdk.sh
}

main() {
	_parse_arg "$@"
	_detect_os
	_detect_versions

	_install_deps
	_add_sgx_repo


	_install_sgxsdk
	_setup_environment
}

main "$@"
