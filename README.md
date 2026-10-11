# Self Hosted LLM
Repo to demo self-hosting LLM on AWS EKS using llm-d router and vLLM model serving engine.

## Overview

## Cost 

## Prerequisite
* AWS CLI, HF_TOKEN, kubectl, Terraform backend buckets

## Deployment Steps

### Clone repo

1. Clone this GitHub Repo

    `git clone https://github.com/mohzim/self-hosted-llm.git`


### Setup resources on AWS Cloud   

2. Initialize terraform

    `terraform -chdir=terraform init -backend-config="bucket=mohzim-terraform" -backend-config="key=terraform-self-hosted-llm-tfstate" -backend-config="region=ap-south-1" -input=false`

3. Verify resource creation
        
    `terraform -chdir=terraform plan -input=false`

4. Create resources in AWS Cloud
        
    `terraform -chdir=terraform apply -input=false`

### Setup kubectl to connect to AWS Kubernetes Cluster 

5. Update your local kubeconfig (Replace with you eks clustername from step 5)
    ```
    aws eks update-kubeconfig --region us-east-2 --name "eks-cluster-name"
    kubeclt get pods
    ```

### Setup k8s resources

6. Add your Hugging Face Token

    `export HF_TOKEN="YOUR-HF-TOKEN" `

7. Source environment variables

    `source scripts/env.sh`

8. Install the Gateway API Inference Extension CRDs and create target namespace for installation

    ```
    kubectl apply -f https://github.com/kubernetes-sigs/gateway-api-inference-extension/${GAIE_URL}/v1-manifests.yaml
    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
      --from-literal="HF_TOKEN=${HF_TOKEN}" \
      --namespace "${NAMESPACE}" \
      --dry-run=client -o yaml | kubectl apply -f -
    ```

9. Install llm-d router
    ```
    helm install ${GUIDE_NAME} \
      ${ROUTER_STANDALONE_CHART} \
      -f ${ROUTER_BASE_VALUES} \
      ${MONITORING_VALUES} \
      -f ${ROUTER_VALUES} \
      -n ${NAMESPACE} --version ${ROUTER_CHART_VERSION}
    ```

11. Install nvidia device plugin on eks nodes
    ```
    helm repo add nvdp https://nvidia.github.io/k8s-device-plugin
    helm repo update
    helm search repo nvdp --devel
    helm upgrade -i nvdp nvdp/nvidia-device-plugin \
    --namespace nvidia-device-plugin \
    --create-namespace \
    --version 0.20.1
    ```

12. Deploy Model Server
    ```
    kubectl apply -n ${NAMESPACE} \
    -k ${REPO_ROOT}/llm-d-sparse/guides/${GUIDE_NAME}/modelserver/${ACCELERATOR_TYPE}/${MODEL_SERVER}/${INFRA_PROVIDER}/
    ```

## Testign with Curl
13. Get the IP of the Proxy
    ```
    export IP=$(kubectl get service ${GUIDE_NAME}-epp -n ${NAMESPACE} -o jsonpath='{.spec.clusterIP}')
    ```

14. Send Test Requests
    Send a completion request from a temporary pod inside the cluster (model-aware; set MODEL to the name you want to query, e.g. Qwen/Qwen3-32B or openai/gpt-oss-120b):
    ```
    kubectl run curl-test --rm -i --restart=Never \
      --image=${CURL_TEST_IMAGE} \
      --namespace="${NAMESPACE}" \
      --env="IP=${IP}" \
      --env="MODEL=${MODEL}" \
      -- /bin/sh -c 'curl -sS -X POST "http://${IP}/v1/completions" -H "Content-Type: application/json" -d "{\"model\": \"${MODEL}\", \"prompt\": \"How are you today?\"}"'
    ```

## Clean-up
15. Destroy cloud resources

    `terraform -chdir=terraform destroy -input=false -auto-approve`

## To-do-list
1. Add licensing note for llm-d parser
2. Update terraform init command without any backend prerequisites.   