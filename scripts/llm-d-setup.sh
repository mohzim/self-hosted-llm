#!/usr/bin/env bash
set -o pipefail

REPO_URL="https://github.com/llm-d/llm-d.git"
CLONE_DIR="llm-d-sparse"

# Sparse clone — only downloads blobs for the paths we need
if [ ! -d "${CLONE_DIR}" ]; then
  git clone --sparse --filter=blob:none --depth=1 \
    "${REPO_URL}" "${CLONE_DIR}"

  cd "${CLONE_DIR}"

  git sparse-checkout set --no-cone \
    /guides/env.sh \
    /guides/optimized-baseline/router/optimized-baseline.values.yaml \
    /guides/optimized-baseline/modelserver/gpu/vllm/base \
    /guides/recipes/router/base.values.yaml \
    /guides/recipes/modelserver/base/single-host/default \
    /guides/recipes/modelserver/common \
    /guides/recipes/modelserver/components/images/gpu-vllm/release
else
  echo "Clone already exists at ${CLONE_DIR}, skipping clone."
  cd "${CLONE_DIR}"
fi

# Guide-specific env vars
export REPO_ROOT=$(pwd)
export GUIDE_NAME=optimized-baseline
export NAMESPACE=llm-d-optimized-baseline
export ACCELERATOR_TYPE=gpu
export MODEL_SERVER=vllm
export INFRA_PROVIDER=base
export MODEL=Qwen/Qwen3-32B
export MONITORING_VALUES=

# Source shared env (sets ROUTER_CHART_VERSION, ROUTER_STANDALONE_CHART, GAIE_URL, etc.)
source "${REPO_ROOT}/guides/env.sh"

# Router helm values paths
export ROUTER_BASE_VALUES="${REPO_ROOT}/guides/recipes/router/base.values.yaml"
export ROUTER_VALUES="${REPO_ROOT}/guides/${GUIDE_NAME}/router/${GUIDE_NAME}.values.yaml"

# Verify all files exist
echo "Verifying files..."
for f in \
  "${REPO_ROOT}/guides/env.sh" \
  "${ROUTER_BASE_VALUES}" \
  "${ROUTER_VALUES}" \
  "${REPO_ROOT}/guides/${GUIDE_NAME}/modelserver/${ACCELERATOR_TYPE}/${MODEL_SERVER}/${INFRA_PROVIDER}/kustomization.yaml"; do
  [ -f "$f" ] && echo "  OK: $f" || { echo "  MISSING: $f"; exit 1; }
done

echo ""
echo "Environment ready. Variables set:"
echo "  REPO_ROOT=${REPO_ROOT}"
echo "  GUIDE_NAME=${GUIDE_NAME}"
echo "  NAMESPACE=${NAMESPACE}"
echo "  ROUTER_STANDALONE_CHART=${ROUTER_STANDALONE_CHART}"
echo "  ROUTER_CHART_VERSION=${ROUTER_CHART_VERSION}"
echo "  ROUTER_BASE_VALUES=${ROUTER_BASE_VALUES}"
echo "  ROUTER_VALUES=${ROUTER_VALUES}"
echo "  MONITORING_VALUES=${MONITORING_VALUES:-(empty)}"
echo "  ACCELERATOR_TYPE=${ACCELERATOR_TYPE}"
echo "  MODEL_SERVER=${MODEL_SERVER}"
echo "  INFRA_PROVIDER=${INFRA_PROVIDER}"
echo ""
echo "Source this script to keep vars in your shell:"
echo "  source llm-d-setup.sh"

echo "Customizing Kubernetes resources to run on single GPU"

sed -i '' 's/model: Qwen3-32B/model: Qwen2.5-1.5B/' guides/optimized-baseline/modelserver/gpu/vllm/base/kustomization.yaml
sed -i '' 's/replicas: 8/replicas: 1/' guides/optimized-baseline/modelserver/gpu/vllm/base/patch-vllm.yaml
sed -i '' 's/Qwen3-32B/Qwen2.5-1.5B/' guides/optimized-baseline/modelserver/gpu/vllm/base/patch-vllm.yaml
sed -i '' 's/tensor-parallel-size=2/tensor-parallel-size=1/' guides/optimized-baseline/modelserver/gpu/vllm/base/patch-vllm.yaml
sed -i '' \
  -e '/limits:/,/nvidia.com\/gpu/{
        s/cpu: .*/cpu: "3"/
        s/memory: .*/memory: 12Gi/
        s/nvidia.com\/gpu: .*/nvidia.com\/gpu: 1/
      }' \
  -e '/requests:/,/nvidia.com\/gpu/{
        s/cpu: .*/cpu: "2"/
        s/memory: .*/memory: 8Gi/
        s/nvidia.com\/gpu: .*/nvidia.com\/gpu: 1/
      }' \
  guides/optimized-baseline/modelserver/gpu/vllm/base/patch-vllm.yaml

echo "Custization Complete"
