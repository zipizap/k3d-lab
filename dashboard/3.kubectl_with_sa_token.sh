#set -x
SvcAccount_NAME="${1:-kubernetes-dashboard}" ; shift 1
SECRET_NAME=$(kubectl -n kubernetes-dashboard get serviceaccount "${SvcAccount_NAME}" -o=jsonpath='{.secrets[0].name}')
TOKEN=$(kubectl -n kubernetes-dashboard get secret $SECRET_NAME -o=jsonpath='{.data.token}' | base64 -d)
kubectl \
    --token $TOKEN \
    ${@}



