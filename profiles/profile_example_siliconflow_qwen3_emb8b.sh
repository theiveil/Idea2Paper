#!/usr/bin/env bash
# Embedding profile example: SiliconFlow + Qwen3-Embedding-8B
# Usage: source profiles/profile_example_siliconflow_qwen3_emb8b.sh

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  echo "Please source this file instead of executing it:"
  echo "  source profiles/profile_example_siliconflow_qwen3_emb8b.sh"
  exit 1
fi

export EMBEDDING_PROVIDER="siliconflow"
export EMBEDDING_API_URL="https://api.siliconflow.cn/v1/embeddings"
export EMBEDDING_MODEL="Qwen/Qwen3-Embedding-8B"
# NOTE: Do NOT put keys here. Use .env or export EMBEDDING_API_KEY in your shell.

_model_sanitized=$(printf "%s" "${EMBEDDING_MODEL}" | tr '/ ' '__' | tr -cd 'A-Za-z0-9._-')
_provider_sanitized=$(printf "%s" "${EMBEDDING_PROVIDER}" | tr '/ ' '__' | tr -cd 'A-Za-z0-9._-')
_url_hash=$(python -c "import hashlib,os;print(hashlib.sha256(os.environ['EMBEDDING_API_URL'].encode()).hexdigest()[:8])")
export PROFILE_ID="${_provider_sanitized}__${_model_sanitized}__${_url_hash}"

export I2P_NOVELTY_INDEX_DIR="Paper-KG-Pipeline/output/novelty_index__${PROFILE_ID}"
export I2P_RECALL_INDEX_DIR="Paper-KG-Pipeline/output/recall_index__${PROFILE_ID}"

echo "[profile] EMBEDDING_PROVIDER=$EMBEDDING_PROVIDER"
echo "[profile] EMBEDDING_API_URL=$EMBEDDING_API_URL"
echo "[profile] EMBEDDING_MODEL=$EMBEDDING_MODEL"
echo "[profile] I2P_NOVELTY_INDEX_DIR=$I2P_NOVELTY_INDEX_DIR"
echo "[profile] I2P_RECALL_INDEX_DIR=$I2P_RECALL_INDEX_DIR"
