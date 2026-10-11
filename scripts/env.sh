#!/usr/bin/env bash
set -o pipefail

# Guide-specific env vars
export REPO_ROOT=$(realpath $(git rev-parse --show-toplevel))
export GUIDE_NAME=optimized-baseline
export NAMESPACE=llm-d-optimized-baseline
export ACCELERATOR_TYPE=gpu
export MODEL_SERVER=vllm
export INFRA_PROVIDER=base
export MODEL=Qwen/Qwen2.5-1.5B
export MONITORING_VALUES= 

# Router helm values paths
export ROUTER_BASE_VALUES="${REPO_ROOT}/llm-d-sparse/guides/recipes/router/base.values.yaml"
export ROUTER_VALUES="${REPO_ROOT}/llm-d-sparse/guides/${GUIDE_NAME}/router/${GUIDE_NAME}.values.yaml"


export PROVIDER_NAME=none # options: none, gke, agentgateway, istio
export CURL_TEST_IMAGE=cfmanteiga/alpine-bash-curl-jq:latest
export BENCHMARK_REF=main
export HARNESS=inference-perf
export WORKLOAD=guide_optimized-baseline_1.yaml
export GATEWAY_CLASS=epponly # options: epponly, gke, agentgateway, istio

### Release Versions for grabbing CRDs
# The *_URL variables are recomputed on every source; a *_URL value exported
# beforehand is discarded. To pin a release, export the matching *_VERSION.
export GATEWAY_API_VERSION=${GATEWAY_API_VERSION:-latest}
if [[ $GATEWAY_API_VERSION == "latest" ]]; then
  export GATEWAY_API_URL=releases/latest/download
else
  export GATEWAY_API_URL=releases/download/${GATEWAY_API_VERSION}
fi
# Controls which release of Gateway API Inference Extension to grab CRDs from
export GAIE_VERSION=${GAIE_VERSION:-latest}
if [[ $GAIE_VERSION == "latest" ]]; then
  export GAIE_URL=releases/latest/download
else
  export GAIE_URL=releases/download/${GAIE_VERSION}
fi
# Controls which release of llm-d/llm-router to grab CRDs from. Used in flowcontrol guide
export ROUTER_RELEASE_VERSION=${ROUTER_RELEASE_VERSION:-latest}
if [[ $ROUTER_RELEASE_VERSION == "latest" ]]; then
  export ROUTER_RELEASE_URL=releases/latest/download
else
  export ROUTER_RELEASE_URL=releases/download/${ROUTER_RELEASE_VERSION}
fi

### Chart versions and OCI coordinates for router chart
export ROUTER_CHART_VERSION=${ROUTER_CHART_VERSION:-v0}
export ROUTER_STANDALONE_CHART=${ROUTER_STANDALONE_CHART:-oci://ghcr.io/llm-d/charts/llm-d-router-standalone}
export ROUTER_GATEWAY_CHART=${ROUTER_GATEWAY_CHART:-oci://ghcr.io/llm-d/charts/llm-d-router-gateway}

### Container Image coordinates and tag for router chart
export ROUTER_EPP_VERSION=${ROUTER_EPP_VERSION:-main}
export ROUTER_EPP_IMAGE=${ROUTER_EPP_IMAGE:-ghcr.io/llm-d/llm-d-router-endpoint-picker}


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
