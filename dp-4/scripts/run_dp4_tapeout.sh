#!/usr/bin/env bash
set -euo pipefail

# Wrapper for DP-4 runs that reuses the validated DP-1 OpenLANE flow
# and snapshots artifacts into dp-4/results for submission tracking.

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <openlane_path> [--aes-block-bytes N] [--die-area \"x0 y0 x1 y1\"] [--pl-target-density D] [--cleanup]"
  exit 1
fi

OPENLANE_PATH="$1"
shift

AES_BLOCK_BYTES="1"
DIE_AREA="0 0 320.00 240.00"
PL_TARGET_DENSITY="0.61"
DO_CLEANUP="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --aes-block-bytes)
      AES_BLOCK_BYTES="$2"
      shift 2
      ;;
    --die-area)
      DIE_AREA="$2"
      shift 2
      ;;
    --pl-target-density)
      PL_TARGET_DENSITY="$2"
      shift 2
      ;;
    --cleanup)
      DO_CLEANUP="true"
      shift 1
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DP4_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${DP4_DIR}/.." && pwd)"

DP1_DIR="${REPO_ROOT}/dp-1"
DP1_SCRIPT="${DP1_DIR}/scripts/run_synthesis_and_ppa.sh"

if [[ ! -x "${DP1_SCRIPT}" ]]; then
  echo "Error: missing executable script: ${DP1_SCRIPT}"
  exit 1
fi

CMD=(
  "${DP1_SCRIPT}" "${OPENLANE_PATH}"
  --aes-block-bytes "${AES_BLOCK_BYTES}"
  --die-area "${DIE_AREA}"
  --pl-target-density "${PL_TARGET_DENSITY}"
)

if [[ "${DO_CLEANUP}" == "true" ]]; then
  CMD+=(--cleanup)
fi

echo "Running: ${CMD[*]}"
(
  cd "${DP1_DIR}"
  "${CMD[@]}"
)

RUN_ID_FILE="${DP1_DIR}/runs/latest/RUN_ID.txt"
if [[ ! -f "${RUN_ID_FILE}" ]]; then
  echo "Error: expected RUN_ID file not found at ${RUN_ID_FILE}"
  exit 1
fi

RUN_ID="$(cat "${RUN_ID_FILE}")"
DEST_DIR="${DP4_DIR}/results/${RUN_ID}"
mkdir -p "${DEST_DIR}"

cp -f "${RUN_ID_FILE}" "${DEST_DIR}/RUN_ID.txt"
for f in metrics.csv SUMMARY.md manufacturability.rpt openlane_flow.log.txt; do
  if [[ -f "${DP1_DIR}/runs/latest/${f}" ]]; then
    cp -f "${DP1_DIR}/runs/latest/${f}" "${DEST_DIR}/${f}"
  elif [[ -f "${DP1_DIR}/runs/latest/reports/${f}" ]]; then
    cp -f "${DP1_DIR}/runs/latest/reports/${f}" "${DEST_DIR}/${f}"
  fi
done

{
  echo "date=$(date -Iseconds)"
  echo "openlane_path=${OPENLANE_PATH}"
  echo "aes_block_bytes=${AES_BLOCK_BYTES}"
  echo "die_area=${DIE_AREA}"
  echo "pl_target_density=${PL_TARGET_DENSITY}"
  echo "cleanup=${DO_CLEANUP}"
} > "${DEST_DIR}/command.txt"

echo "DP-4 snapshot saved to: ${DEST_DIR}"
