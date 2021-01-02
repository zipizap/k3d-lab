#set -x
#
# USAGE:
#   $0 mysa sa-podlogs get pods 
#

SA_NAME="${1:-mysa}" ; shift 1
SA_NAMESPACE="${1:-sa-podlogs}" ; shift 1

## Extract the SA_TOKEN value
#
# This needs to be a kubeconfig-context that already exists (in current $KUBECONFIG file, or in default ~/.kube/config), and that allows access as cluster-admin. It will be used to gather necessary info about the serviceaccount SA (basically its SECRET and TOKEN)
CLUSTERADMIN_CONTEXT_NAME=k3d-myk3dcluster
SERVER_URL=https://0.0.0.0:33219


SA_SECRET_NAME=$(kubectl --context=$CLUSTERADMIN_CONTEXT_NAME -n $SA_NAMESPACE get serviceaccount "${SA_NAME}" -o=jsonpath='{.secrets[0].name}')
SA_TOKEN=$(kubectl --context=$CLUSTERADMIN_CONTEXT_NAME -n $SA_NAMESPACE get secret $SA_SECRET_NAME -o=jsonpath='{.data.token}' | base64 -d)
# alternative to not-using a clusteradmin-account, could be to previously store the TOKEN in a file, and then everytime it would be needed just read it from the file
# SA_TOKEN=$(cat $SA_NAME.token)



#     API Access Control:
#       - Authentication (basically server/client certifs, client user/pass, client TOKEN :) , password, etc )
#       - Authorization  (basically RBAC (cluster)roles, (cluster)rolebindings)
#       - AdmissionControl (basically automatic-valiation-and-changing of incomming requests, before execution, like a pre-hook... out of scope for now)
#         
#     [2] https://kubernetes.io/docs/concepts/security/controlling-access/
#         - service-accounts use JSON WEBTOKENS (JWT) as an Authentication TOKEN
#         - great overview
#
#     [1] https://kubernetes.io/docs/reference/access-authn-authz/authentication/
#         Good explanation, but does not have any example of how to "kubectl --token"
#
#     [4] https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/
#         Really missed here a couple of examples of how to use the service-account TOKEN, either via HTTP-REST (curl) or kubectl...
#
#     [5] https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
#         Lots of details not found in [4] are clarified here... good reading around service-accounts
#         But still, no clear example of how to use service-account TOKEN by curl or kubectl :)
#
#     [6] somewhere in the kubernetes docs
#         I recall finding 1 example of curl HTTP-REST using header "Authentication: Bearer SA-TOKEN-HERE"
#         an another web indicating clearly that "kubectl --token" should be used to authenticate as a service-account
#         But they were short mentions, and scarce on details... fact is the kubectl --token didn't work for me in first-tries
#         which lead me to deep-dive studying all these details and concepts...
#
#
#     [3] https://kubernetes.io/docs/reference/access-authn-authz/rbac
#         Roles, rolebdindings, ... 
#         There are some interesting things that can be done with Aggregated ClusterRoles... to check out another time
#
#     I could not found an easy way to make "kubectl --token" work... and was hard to find dumbed-down info about it, or very-complete examples 
#     So I made this demo, to try-and-test untill it worked correctly, in a controlled environment
#     Basically when I tried to use "kubectl --token xxxx get pods" there was some *unexpected* conflict with the $KUBECONFIG file (or ~/kube/config)
#     that seemed to be partially reusing some kubeconfig-user values and not just the --token... dint looked further into it, simply put the "kubectl --token" 
#     was not working easily as expected for me.
#     And after all the tests, the conclusion is:
#       1) If you define in your kubeconfig-file a new user containing the TOKEN, and a new context containing that-user with your-cluester, then the "kubectl get pods" will work, without using "--token"
#          See functions cr_sa() kubectl_with_sa_via_kubeconfig()
# 
#       2) If you use an empty-kubeconfig-file (like /dev/null), then with it in $KUBECONFIG you can use "kubectl --token" and it will work, but you'll also have to add some more authentication flags to kubectl for it
#         to know what is your api-server url. This works, and is what this current file does :)
#         Also, in this file there is an upper section that extract the token using a cluster-admin account. This could be replaced by a simple 'SA_TOKEN=$(cat mysa.token)' 
#         to avoid requiring cluster-admin at all and instead just read the token from an existing file
#
#       NOTE: trying "kubectl --as mysa ..." uses the kubeconfig file to read the "user" mysa info ,where you would have to place the token. This would not allow direct "kubectl --token " commands as it requires modification of kubectl-file to ad user/token/context as done in cr_sa()
#

## Run kubectl without any kubeconfig file and 
# - passing the k8s api-server url ignoring its certificate-check
# - using the SA_TOKEN of the serviceaccount, to perform Authentication in the api-server
#   This was the hardest to find clear info about, an the reason to create this
#   small demo: how to use "kubectl --token" correctly
KUBECONFIG=/dev/null  kubectl \
  --server=$SERVER_URL --insecure-skip-tls-verify \
  --token=$SA_TOKEN \
  \
  -n $SA_NAMESPACE \
  ${@}

