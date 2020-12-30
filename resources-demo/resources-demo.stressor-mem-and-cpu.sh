cat <<EOT | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: resources-demo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: resources-demo
  name: stressor-mem
spec:
  selector:
    matchLabels:
      run: stressor-mem
  replicas: 1
  template:
    metadata:
      labels:
        run: stressor-mem
    spec:
      containers:
      - name: stressor-mem
        image: alexeiled/stress-ng
        args: 
        - "--vm"
        - "1"
        - "--vm-bytes"
        - "1G"
        - "--timeout"
        - "5m"
        - "--metrics-brief"
        resources:
          limits:
            memory: 100Mi
          requests:
            memory: 50Mi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: resources-demo
  name: stressor-cpu
spec:
  selector:
    matchLabels:
      run: stressor-cpu
  replicas: 1
  template:
    metadata:
      labels:
        run: stressor-cpu
    spec:
      containers:
      - name: stressor-cpu
        image: alexeiled/stress-ng
        args: 
        - "--cpu"
        - "3"
        - "--timeout"
        - "5m"
        - "--metrics-brief"
        resources:
          limits:
            cpu: 100m
          requests:
            cpu: 100m
EOT


##### stress-ng
# run for 60 seconds with 4 cpu stressors, 2 io stressors and 1 vm stressor using 1GB of virtual memory
# --cpu 4 --io 2 --vm 1 --vm-bytes 1G --timeout 60s --metrics-brief
#
#kubectl -n resources-demo delete pod stress-ng || true
#kubectl -n resources-demo run stress-ng --image=alexeiled/stress-ng --restart=Never -- \
#  --cpu 1 --vm 1 --vm-bytes 1G --timeout 30s --metrics-brief

echo "... sleeping a bit before watching pods resource consumption"
sleep 10
watch kubectl -n resources-demo top pods
