#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ ! -f "./build.env" ]]; then
    echo "[ ERROR ] build.env not found. Cannot execute the script." >&2
    exit 1
fi
source ./build.env

_info() { echo -e "\033[1;34m[INFO]\033[0m $*"; }
_done() { echo -e "\033[1;32m[DONE]\033[0m $*"; }

output_dir="${PWD}/output"

if ! command -v image-builder >/dev/null 2>&1; then
    _info "Installing image-builder..."
    sudo dnf install -y image-builder
fi

_info "Building desktop image: ${LOCAL_IMAGE} (Base: ${BASE_IMAGE})..."
sudo podman build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    -t "${LOCAL_IMAGE}" .

_info "Building Anaconda installer image: ${LOCAL_INSTALLER_IMAGE}..."
sudo podman build \
    --build-arg "BASE_IMAGE=${BASE_IMAGE}" \
    --build-arg "BOOTC_SOURCE_IMGREF=containers-storage:${LOCAL_IMAGE}" \
    --build-arg "BOOTC_TARGET_IMGREF=${TARGET_IMAGE}" \
    --build-arg "ISO_LABEL=${ISO_LABEL}" \
    --build-arg "ISO_TITLE=${ISO_TITLE}" \
    -t "${LOCAL_INSTALLER_IMAGE}" \
    installer/

mkdir -p "${output_dir}"

_info "Building generic-iso installer..."
sudo image-builder build \
    --bootc-ref "${LOCAL_INSTALLER_IMAGE}" \
    --bootc-installer-payload-ref "${LOCAL_IMAGE}" \
    --bootc-default-fs "${DEFAULT_FS}" \
    --output-dir "${output_dir}" \
    generic-iso

_done "Image available at: ${output_dir}"
