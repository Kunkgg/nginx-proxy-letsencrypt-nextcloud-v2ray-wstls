v2ray_log() {
        local type="$1"; shift
        printf '%s [%s] [Entrypoint]: %s\n' "$(date --rfc-2822)" "$type" "$*"
}

v2ray_note() {
        v2ray_log Note "$@"
}
v2ray_warn() {
        v2ray_log Warn "$@" >&2
}
v2ray_error() {
        v2ray_log ERROR "$@" >&2
        exit 1
}

v2ray_download() {
    # Set ARG
    if [[ -z $1 ]]; then
        PLATFORM="linux/amd64"
    else
        PLATFORM=$1
    fi
    if [ -z "$PLATFORM" ]; then
        ARCH="64"
    else
        case "$PLATFORM" in
            linux/386)
                ARCH="32"
                ;;
            linux/amd64)
                ARCH="64"
                ;;
            linux/arm/v6)
                ARCH="arm32-v6"
                ;;
            linux/arm/v7)
                ARCH="arm32-v7a"
                ;;
            linux/arm64|linux/arm64/v8)
                ARCH="arm64-v8a"
                ;;
            linux/ppc64le)
                ARCH="ppc64le"
                ;;
            linux/s390x)
                ARCH="s390x"
                ;;
            *)
                ARCH=""
                ;;
        esac
    fi
    [ -z "${ARCH}" ] && v2ray_error "Error: Not supported OS Architecture"

    # Download files
    V2RAY_FILE="v2ray-linux-${ARCH}.zip"
    DGST_FILE="v2ray-linux-${ARCH}.zip.dgst"
    v2ray_note "Downloading binary file: ${V2RAY_FILE}"
    v2ray_note "Downloading binary file: ${DGST_FILE}"

    TAG=$(wget -qO- https://raw.githubusercontent.com/v2fly/docker/master/ReleaseTag | head -n1)
    v2ray_note "tag: ${TAG}"
    v2ray_note "v2ray.zip url: https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${V2RAY_FILE}"
    v2ray_note "v2ray.zip.dgst url: https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${DGST_FILE}"
    wget -O ${PWD}/v2ray.zip https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${V2RAY_FILE} > /dev/null 2>&1
    wget -O ${PWD}/v2ray.zip.dgst https://github.com/v2fly/v2ray-core/releases/download/${TAG}/${DGST_FILE} > /dev/null 2>&1

    if [ $? -ne 0 ]; then
        v2ray_error "Error: Failed to download binary file: ${V2RAY_FILE} ${DGST_FILE}"
    fi
    v2ray_note "Download binary file: ${V2RAY_FILE} ${DGST_FILE} completed"

    # Check SHA512
    LOCAL=$(openssl dgst -sha512 v2ray.zip | sed 's/([^)]*)//g')
    STR=$(cat v2ray.zip.dgst | grep 'SHA512' | head -n1)

    if [ "${LOCAL}" = "${STR}" ]; then
        v2ray_note " Check passed" && rm -fv v2ray.zip.dgst
    else
        v2ray_error " Check have not passed yet "
    fi
}

# delete the old version
if [[ -E ./v2ray.zip ]]; then
    rm -f ./v2ray.zip
fi

v2ray_download "$@"
