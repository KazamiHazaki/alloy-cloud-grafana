#!/usr/bin/env sh
# shellcheck shell=dash

set -eu
trap "exit 1" TERM
MY_PID=$$

log() {
  echo "$@" >&2
}

fatal() {
  log "$@"
  kill -s TERM "${MY_PID}"
}

detect_curl() {
  command -v curl >/dev/null 2>&1 || { fatal "Could not detect curl. Please install curl and re-run this script."; exit 1; }
}

detect_unzip() {
  command -v unzip >/dev/null 2>&1 || { fatal "Could not detect unzip. Please install unzip and re-run this script."; exit 1; }
}

SHA256_SUMS="
# BEGIN_SHA256_SUMS
5369ff0b66a6bb8300ec3f1ca2666272a073224d935c8881b53b8f5b9a9517a6  alloy-linux-amd64.zip
e28c774c90ed00934e561e1f1ff08e607ec79e4d12da0612627289466180ea5a  alloy-linux-arm64.zip
# END_SHA256_SUMS
"

CONFIG_SHA256_SUMS="
# BEGIN_CONFIG_SHA256_SUMS
cf9f959c4718bcab1f80595751c0573342ac147194a578f0d2743dca248e3a83  config.alloy
# END_CONFIG_SHA256_SUMS
"

#
# REQUIRED environment variables.
#
ARCH=${ARCH:=}                                             # System architecture
GCLOUD_HOSTED_METRICS_URL=${GCLOUD_HOSTED_METRICS_URL:=}   # Grafana Cloud Hosted Metrics url
GCLOUD_HOSTED_METRICS_ID=${GCLOUD_HOSTED_METRICS_ID:=}     # Grafana Cloud Hosted Metrics Instance ID
GCLOUD_SCRAPE_INTERVAL=${GCLOUD_SCRAPE_INTERVAL:=}         # Grafana Cloud Hosted Metrics scrape interval
GCLOUD_HOSTED_LOGS_URL=${GCLOUD_HOSTED_LOGS_URL:=}         # Grafana Cloud Hosted Logs url
GCLOUD_HOSTED_LOGS_ID=${GCLOUD_HOSTED_LOGS_ID:=}           # Grafana Cloud Hosted Logs Instance ID
GCLOUD_RW_API_KEY=${GCLOUD_RW_API_KEY:=}                   # Grafana Cloud API key

[ -z "${ARCH}" ] && fatal "Required environment variable \$ARCH not set."
[ -z "${GCLOUD_HOSTED_METRICS_URL}" ] && fatal "Required environment variable \$GCLOUD_HOSTED_METRICS_URL not set."
[ -z "${GCLOUD_HOSTED_METRICS_ID}" ]  && fatal "Required environment variable \$GCLOUD_HOSTED_METRICS_ID not set."
[ -z "${GCLOUD_SCRAPE_INTERVAL}" ]  && fatal "Required environment variable \$GCLOUD_SCRAPE_INTERVAL not set."
[ -z "${GCLOUD_HOSTED_LOGS_URL}" ] && fatal "Required environment variable \$GCLOUD_HOSTED_LOGS_URL not set."
[ -z "${GCLOUD_HOSTED_LOGS_ID}" ]  && fatal "Required environment variable \$GCLOUD_HOSTED_LOGS_ID not set."
[ -z "${GCLOUD_RW_API_KEY}" ]  && fatal "Required environment variable \$GCLOUD_RW_API_KEY not set."

#
# Global constants.
#
GRAFANA_ALLOY_CONFIG="https://storage.googleapis.com/cloud-onboarding/alloy/config/config.alloy"
RELEASE_VERSION="v1.3.1"
RELEASE_URL="https://github.com/grafana/alloy/releases/download/${RELEASE_VERSION}"

# Enable or disable use of systemctl.
RUN_ALLOY=${RUN_ALLOY:-1}

download_alloy() {
  ASSET_NAME="alloy-linux-${ARCH}.zip"
  ASSET_URL="${RELEASE_URL}/${ASSET_NAME}"

  curl -O -L "${ASSET_URL}"
  log '--- Verifying package checksum'
  check_sha "${SHA256_SUMS}" "${ASSET_NAME}"

  unzip "${ASSET_NAME}"
  chmod a+x "alloy-linux-${ARCH}"
}

# download_config downloads the config file for Alloy and replaces
# placeholders with actual values.
download_config() {
  TMP_CONFIG_FILE="/tmp/config.alloy"
  curl -fsSL "${GRAFANA_ALLOY_CONFIG}" -o "${TMP_CONFIG_FILE}" || fatal 'Failed to download config'
  (cd /tmp && check_sha "${CONFIG_SHA256_SUMS}" "config.alloy")

  sed -i -e "s~{GCLOUD_RW_API_KEY}~${GCLOUD_RW_API_KEY}~g" "${TMP_CONFIG_FILE}"
  sed -i -e "s~{GCLOUD_HOSTED_METRICS_URL}~${GCLOUD_HOSTED_METRICS_URL}~g" "${TMP_CONFIG_FILE}"
  sed -i -e "s~{GCLOUD_HOSTED_METRICS_ID}~${GCLOUD_HOSTED_METRICS_ID}~g" "${TMP_CONFIG_FILE}"
  sed -i -e "s~{GCLOUD_SCRAPE_INTERVAL}~${GCLOUD_SCRAPE_INTERVAL}~g" "${TMP_CONFIG_FILE}"
  sed -i -e "s~{GCLOUD_HOSTED_LOGS_URL}~${GCLOUD_HOSTED_LOGS_URL}~g" "${TMP_CONFIG_FILE}"
  sed -i -e "s~{GCLOUD_HOSTED_LOGS_ID}~${GCLOUD_HOSTED_LOGS_ID}~g" "${TMP_CONFIG_FILE}"

  mv "${TMP_CONFIG_FILE}" ./config.alloy
}

check_sha() {
  local checksums="$1"
  local asset_name="$2"
  shift 2

  echo -n "${checksums}" | grep "${asset_name}" | sha256sum --check --status --quiet - || fatal 'Failed sha256sum check'
}

main() {
  detect_curl
  detect_unzip

  log "--- Downloading Alloy version ${RELEASE_VERSION}"
  download_alloy

  log "--- Retrieving config and placing in './config.alloy'"
  download_config
}

main
