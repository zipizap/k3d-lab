cat <<EOT | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: hpa-demo
---
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: hpa-demo
  name: php-apache
spec:
  selector:
    matchLabels:
      run: php-apache
  replicas: 1
  template:
    metadata:
      labels:
        run: php-apache
    spec:
      containers:
      - name: php-apache
        image: k8s.gcr.io/hpa-example
        ports:
        - containerPort: 80
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
---
#kubectl -n hpa-demo autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10
apiVersion: v1
kind: Service
metadata:
  namespace: hpa-demo
  name: php-apache
  labels:
    run: php-apache
spec:
  ports:
  - port: 80
  selector:
    run: php-apache
---
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  namespace: hpa-demo
  name: php-apache
spec:
  maxReplicas: 10
  minReplicas: 1
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: php-apache
  targetCPUUtilizationPercentage: 50
EOT

kubectl -n hpa-demo get hpa

#kubectl -n hpa-demo run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "for i in $(seq 1 10); do sleep 0.01; wget -q -O- http://php-apache; done"
kubectl -n hpa-demo run load-generator --image=busybox --restart=Never -- /bin/sh -c 'for i in $(seq 1 200000000); do sleep 0.001; echo $i ; wget -q -O- http://php-apache; done'
watch 'kubectl -n hpa-demo get hpa -o wide ; kubectl -n hpa-demo logs load-generator | tail'
