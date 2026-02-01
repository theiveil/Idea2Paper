#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: ./scripts/run_with_profile.sh profiles/<profile>.sh \"your idea\""
  exit 1
fi

profile_path="$1"
shift
idea="$*"

if [ -z "${idea}" ]; then
  echo "Error: idea is empty."
  exit 1
fi

REPO_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

if [[ "${profile_path}" != /* ]]; then
  profile_path="${REPO_ROOT}/${profile_path}"
fi

if [ ! -f "${profile_path}" ]; then
  echo "Error: profile not found: ${profile_path}"
  exit 1
fi

# shellcheck disable=SC1090
source "${profile_path}"

echo "[run] EMBEDDING_PROVIDER=${EMBEDDING_PROVIDER:-}"
echo "[run] EMBEDDING_API_URL=${EMBEDDING_API_URL:-}"
echo "[run] EMBEDDING_MODEL=${EMBEDDING_MODEL:-}"
echo "[run] I2P_NOVELTY_INDEX_DIR=${I2P_NOVELTY_INDEX_DIR:-}"
echo "[run] I2P_RECALL_INDEX_DIR=${I2P_RECALL_INDEX_DIR:-}"
if [ -z "${EMBEDDING_API_KEY:-}" ] && [ -z "${SILICONFLOW_API_KEY:-}" ]; then
  echo "[run] warning: EMBEDDING_API_KEY and SILICONFLOW_API_KEY are both empty."
fi

python "${REPO_ROOT}/Paper-KG-Pipeline/scripts/idea2story_pipeline.py" "${idea}"
