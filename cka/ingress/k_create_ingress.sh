kubectl create ingress myingress \
  --annotation ingress.annotation1=foo \
  --annotation ingress.annotation2=bla \
\
\
\
\
\
\
\
  --default-backend=defaultbackendsvc:http                      `# default-backend` \
\
\
\
  --class=myIngressClass-or-default                           `# ingress class` \
\
  --rule="/anyHost=svc1:8080"                                 `# any host *`        \
\
\
\
\
\
\
\
\
  --rule="host1-with-tls.com/aaa=svc1:http,tls=my-cert"       `# with tls`        \
\
\
\
\
\
\
\
\
\
  --rule="with.path.prefix.com/*=svc:8080"                    `# pathType prefix`   \
\
\
\
\
\
\
\
\
\
  --rule="with.path.prefix.com/aPref*=svc:8080"              `# pathType prefix` \
\
\
  -o yaml --dry-run=client > ingress.yaml
vi ingress.yaml
